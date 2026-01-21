-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS citext;

-- 1. PROFILES (Player Identity & Progress)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    nickname CITEXT UNIQUE, -- Case-insensitive unique nickname
    country_iso2 CHAR(2) DEFAULT 'BR',
    avatar_id TEXT DEFAULT 'default_avatar',
    
    -- Progression
    level INT DEFAULT 1,
    xp INT DEFAULT 0,
    trophies INT DEFAULT 0,
    current_arena_id INT DEFAULT 1,
    
    -- Economy
    coins INT DEFAULT 0 CHECK (coins >= 0),
    rubies INT DEFAULT 0 CHECK (rubies >= 0),
    runes INT DEFAULT 0 CHECK (runes >= 0),
    
    -- Meta
    settings JSONB DEFAULT '{"sound": true, "music": true, "language": "pt-BR"}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. CARDS (Global Catalog)
CREATE TABLE IF NOT EXISTS public.cards (
    id TEXT PRIMARY KEY, -- e.g., 'c_fireball', 'u_knight'
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('unit', 'spell', 'building')),
    rarity TEXT NOT NULL CHECK (rarity IN ('common', 'rare', 'epic', 'legendary')),
    cost INT NOT NULL DEFAULT 1,
    
    -- Stats (JSONB allows flexibility for different card types)
    -- Ex: {"hp": 100, "damage": 50, "speed": 1.2, "range": 5.0}
    base_stats JSONB NOT NULL DEFAULT '{}'::jsonb,
    
    -- Visual/Meta
    asset_path TEXT,
    description TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. USER_CARDS (Collection & Upgrades)
CREATE TABLE IF NOT EXISTS public.user_cards (
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    card_id TEXT REFERENCES public.cards(id) ON DELETE CASCADE,
    
    level INT DEFAULT 1,
    fragments INT DEFAULT 0,
    is_obtained BOOLEAN DEFAULT FALSE,
    obtained_at TIMESTAMPTZ,
    
    PRIMARY KEY (user_id, card_id)
);

-- 4. DECKS (Loadouts)
CREATE TABLE IF NOT EXISTS public.decks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    name TEXT DEFAULT 'Deck 1',
    is_active BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. DECK_CARDS (Cards in a Deck)
CREATE TABLE IF NOT EXISTS public.deck_cards (
    deck_id UUID REFERENCES public.decks(id) ON DELETE CASCADE,
    card_id TEXT REFERENCES public.cards(id) ON DELETE CASCADE,
    position INT NOT NULL CHECK (position >= 0 AND position < 8), -- 8 cards per deck
    
    PRIMARY KEY (deck_id, position)
);

-- 6. MATCHES (History)
CREATE TABLE IF NOT EXISTS public.matches (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    player_id UUID REFERENCES public.profiles(id),
    opponent_id UUID REFERENCES public.profiles(id), -- Can be null for bots
    
    winner_id UUID, -- Null if draw
    arena_id INT,
    duration_seconds INT,
    
    replay_data_id TEXT, -- Link to storage bucket
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. LEDGER (Economy Audit)
CREATE TABLE IF NOT EXISTS public.ledger (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id),
    
    currency TEXT NOT NULL CHECK (currency IN ('coins', 'rubies', 'runes')),
    amount INT NOT NULL, -- Positive for gain, negative for spend
    source TEXT NOT NULL, -- e.g., 'match_reward', 'shop_purchase', 'upgrade_card'
    
    balance_after INT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- INDEXES
-- =============================================================================
CREATE INDEX IF NOT EXISTS idx_profiles_nickname ON public.profiles (nickname);
CREATE INDEX IF NOT EXISTS idx_profiles_trophies ON public.profiles (trophies DESC); -- Leaderboard
CREATE INDEX IF NOT EXISTS idx_user_cards_user ON public.user_cards (user_id);
CREATE INDEX IF NOT EXISTS idx_matches_player ON public.matches (player_id);

-- =============================================================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.decks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deck_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ledger ENABLE ROW LEVEL SECURITY;

-- Profiles: Public read (for opponent info), Owner write
CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can insert their own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Cards: Public read, Admin write (disable write for users)
CREATE POLICY "Cards are viewable by everyone" ON public.cards FOR SELECT USING (true);

-- User Cards: Owner read/write (Logic usually handled via RPC for security, but basic RLS here)
CREATE POLICY "Users view own cards" ON public.user_cards FOR SELECT USING (auth.uid() = user_id);
-- Note: Updates to user_cards usually happen via trusted functions to prevent cheating

-- Decks: Owner read/write
CREATE POLICY "Users view own decks" ON public.decks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users update own decks" ON public.decks FOR ALL USING (auth.uid() = user_id);

-- Deck Cards: Owner read/write (via deck join)
CREATE POLICY "Users manage deck cards" ON public.deck_cards FOR ALL USING (
    EXISTS (SELECT 1 FROM public.decks WHERE id = deck_cards.deck_id AND user_id = auth.uid())
);

-- Matches: Participants read
CREATE POLICY "Users view their matches" ON public.matches FOR SELECT USING (
    auth.uid() = player_id OR auth.uid() = opponent_id
);

-- Ledger: Owner read
CREATE POLICY "Users view own ledger" ON public.ledger FOR SELECT USING (auth.uid() = user_id);

-- =============================================================================
-- TRIGGERS & FUNCTIONS
-- =============================================================================

-- 1. Auto Update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_profiles_modtime BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_decks_modtime BEFORE UPDATE ON public.decks FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- 2. Auto Create Profile on Signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, nickname, country_iso2)
  VALUES (NEW.id, NULL, 'BR'); -- Nickname starts NULL, set via onboarding
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on auth.users (Requires admin privileges to set up in dashboard usually, but SQL provided here)
-- CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- =============================================================================
-- RPC FUNCTIONS (Game Logic)
-- =============================================================================

-- 1. Claim Nickname (Onboarding)
CREATE OR REPLACE FUNCTION claim_nickname_and_country(
    p_nickname TEXT,
    p_country TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID;
    v_profile RECORD;
BEGIN
    v_user_id := auth.uid();
    
    -- Check if nickname is taken (case insensitive due to CITEXT)
    IF EXISTS (SELECT 1 FROM public.profiles WHERE nickname = p_nickname AND id != v_user_id) THEN
        RAISE EXCEPTION 'Nickname already taken';
    END IF;

    -- Update Profile
    UPDATE public.profiles
    SET nickname = p_nickname,
        country_iso2 = p_country,
        updated_at = NOW()
    WHERE id = v_user_id
    RETURNING * INTO v_profile;

    RETURN to_jsonb(v_profile);
END;
$$;

-- 2. Get Full Player State (Fast Load)
CREATE OR REPLACE FUNCTION get_full_player_state()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID;
    v_profile JSONB;
    v_cards JSONB;
    v_decks JSONB;
BEGIN
    v_user_id := auth.uid();

    -- Fetch Profile
    SELECT to_jsonb(p) INTO v_profile FROM public.profiles p WHERE id = v_user_id;
    
    -- Fetch Cards
    SELECT jsonb_agg(
        jsonb_build_object(
            'card_id', uc.card_id,
            'level', uc.level,
            'fragments', uc.fragments,
            'is_obtained', uc.is_obtained,
            'def', (SELECT to_jsonb(c) FROM public.cards c WHERE c.id = uc.card_id)
        )
    ) INTO v_cards
    FROM public.user_cards uc
    WHERE uc.user_id = v_user_id;

    -- Fetch Decks
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', d.id,
            'name', d.name,
            'is_active', d.is_active,
            'cards', (
                SELECT jsonb_agg(dc.card_id)
                FROM public.deck_cards dc
                WHERE dc.deck_id = d.id
                ORDER BY dc.position
            )
        )
    ) INTO v_decks
    FROM public.decks d
    WHERE d.user_id = v_user_id;

    RETURN jsonb_build_object(
        'profile', v_profile,
        'collection', COALESCE(v_cards, '[]'::jsonb),
        'decks', COALESCE(v_decks, '[]'::jsonb)
    );
END;
$$;
