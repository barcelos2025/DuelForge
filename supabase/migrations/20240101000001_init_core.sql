-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS citext;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- -----------------------------------------------------------------------------
-- 1. PROFILES
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nickname CITEXT UNIQUE,
    country_iso2 CHAR(2) DEFAULT 'BR',
    avatar_id TEXT DEFAULT 'default_avatar',
    
    -- Progress
    level INT DEFAULT 1,
    xp INT DEFAULT 0,
    trophies INT DEFAULT 0,
    current_arena_id INT DEFAULT 1,
    
    -- Economy
    coins INT DEFAULT 1000,
    rubies INT DEFAULT 100,
    runes INT DEFAULT 0,
    
    -- Meta
    settings JSONB DEFAULT '{"sound": true, "music": true, "language": "pt-BR", "vfx_quality": "high"}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS: Profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile" 
ON public.profiles FOR SELECT 
USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
ON public.profiles FOR UPDATE 
USING (auth.uid() = id);

-- Public read access for matchmaking/leaderboards (limited columns ideally, but full read for now)
CREATE POLICY "Public profiles are viewable by everyone" 
ON public.profiles FOR SELECT 
USING (true);

-- -----------------------------------------------------------------------------
-- 2. CARDS (Global Catalog)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.cards (
    id TEXT PRIMARY KEY, -- e.g., 'unit_bear_berserker'
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('unit', 'spell', 'building')),
    rarity TEXT NOT NULL CHECK (rarity IN ('common', 'rare', 'epic', 'legendary')),
    elixir_cost INT NOT NULL DEFAULT 3,
    base_stats JSONB DEFAULT '{}'::jsonb, -- { "hp": 1000, "damage": 150, "speed": 1.2, "range": 0 }
    asset_path TEXT,
    description TEXT,
    is_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS: Cards
ALTER TABLE public.cards ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Cards are viewable by everyone" ON public.cards FOR SELECT USING (true);

-- -----------------------------------------------------------------------------
-- 3. ARENAS
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.arenas (
    id INT PRIMARY KEY,
    name TEXT NOT NULL,
    unlock_trophies INT NOT NULL DEFAULT 0,
    asset_path TEXT,
    theme_key TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS: Arenas
ALTER TABLE public.arenas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Arenas are viewable by everyone" ON public.arenas FOR SELECT USING (true);

-- -----------------------------------------------------------------------------
-- 4. USER CARDS (Collection)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.user_cards (
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    card_id TEXT REFERENCES public.cards(id) ON DELETE CASCADE,
    level INT DEFAULT 1,
    fragments INT DEFAULT 0,
    is_obtained BOOLEAN DEFAULT false,
    obtained_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, card_id)
);

-- RLS: User Cards
ALTER TABLE public.user_cards ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own cards" ON public.user_cards FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own cards" ON public.user_cards FOR UPDATE USING (auth.uid() = user_id);

-- -----------------------------------------------------------------------------
-- 5. DECKS
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.decks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    name TEXT DEFAULT 'Deck 1',
    is_active BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS: Decks
ALTER TABLE public.decks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own decks" ON public.decks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own decks" ON public.decks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own decks" ON public.decks FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own decks" ON public.decks FOR DELETE USING (auth.uid() = user_id);

-- -----------------------------------------------------------------------------
-- 6. DECK CARDS (Join Table)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.deck_cards (
    deck_id UUID REFERENCES public.decks(id) ON DELETE CASCADE,
    card_id TEXT REFERENCES public.cards(id) ON DELETE CASCADE,
    position INT CHECK (position >= 0 AND position < 8),
    PRIMARY KEY (deck_id, position)
);

-- RLS: Deck Cards
ALTER TABLE public.deck_cards ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own deck cards" 
ON public.deck_cards FOR SELECT 
USING (EXISTS (SELECT 1 FROM public.decks WHERE id = deck_cards.deck_id AND user_id = auth.uid()));

CREATE POLICY "Users can manage own deck cards" 
ON public.deck_cards FOR ALL 
USING (EXISTS (SELECT 1 FROM public.decks WHERE id = deck_cards.deck_id AND user_id = auth.uid()));

-- -----------------------------------------------------------------------------
-- 7. LEDGER (Economy Audit)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ledger (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(id),
    currency TEXT NOT NULL CHECK (currency IN ('coins', 'rubies', 'runes')),
    amount INT NOT NULL, -- Positive for gain, negative for spend
    source TEXT NOT NULL, -- e.g., 'match_reward', 'shop_purchase', 'upgrade_card'
    balance_after INT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS: Ledger
ALTER TABLE public.ledger ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own ledger" ON public.ledger FOR SELECT USING (auth.uid() = user_id);

-- -----------------------------------------------------------------------------
-- TRIGGERS: Updated At
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_cards_updated_at BEFORE UPDATE ON public.cards FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_user_cards_updated_at BEFORE UPDATE ON public.user_cards FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_decks_updated_at BEFORE UPDATE ON public.decks FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
