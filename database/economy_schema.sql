-- ==============================================================================
-- DUELFORGE: ODYN'S RAGE - COMPLETE ECONOMY & PROGRESSION SCHEMA (FAILSAFE V4)
-- ==============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ------------------------------------------------------------------------------
-- 1. ENUMS & TYPES (Idempotent)
-- ------------------------------------------------------------------------------

DO $$ BEGIN
    CREATE TYPE card_rarity AS ENUM ('common', 'rare', 'epic', 'legendary');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE card_type AS ENUM ('troop', 'building', 'spell');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE chest_state AS ENUM ('locked', 'unlocking', 'ready', 'opened');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE currency_type AS ENUM ('gold', 'runes', 'trophies');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- ------------------------------------------------------------------------------
-- 2. CORE TABLES (Create if not exists)
-- ------------------------------------------------------------------------------

-- PLAYERS
CREATE TABLE IF NOT EXISTS public.players (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    game_name TEXT,
    country_code CHAR(2),
    gold BIGINT DEFAULT 0 CHECK (gold >= 0),
    runes BIGINT DEFAULT 0 CHECK (runes >= 0),
    trophies INT DEFAULT 0 CHECK (trophies >= 0),
    arena_id TEXT DEFAULT 'arena_1',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- CARD CATALOG
CREATE TABLE IF NOT EXISTS public.card_catalog (
    card_id TEXT PRIMARY KEY,
    slug TEXT NOT NULL,
    name TEXT NOT NULL,
    rarity card_rarity NOT NULL,
    type card_type NOT NULL,
    is_premium_acquisition BOOLEAN DEFAULT FALSE,
    unlock_parts_required INT DEFAULT 6,
    enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- CARD ASSETS
CREATE TABLE IF NOT EXISTS public.card_assets (
    card_id TEXT PRIMARY KEY REFERENCES public.card_catalog(card_id) ON DELETE CASCADE,
    image_url TEXT,
    model_url TEXT,
    icon_url TEXT,
    vfx_config_json JSONB
);

-- CARD BALANCE PROFILE
CREATE TABLE IF NOT EXISTS public.card_balance_profile (
    id SERIAL PRIMARY KEY,
    card_id TEXT REFERENCES public.card_catalog(card_id) ON DELETE CASCADE,
    level INT NOT NULL,
    hp INT,
    damage INT,
    speed FLOAT,
    attack_speed FLOAT,
    range FLOAT,
    is_placeholder BOOLEAN DEFAULT FALSE
);

-- CARD UPGRADE REQUIREMENTS
CREATE TABLE IF NOT EXISTS public.card_upgrade_requirements (
    id SERIAL PRIMARY KEY,
    rarity card_rarity NOT NULL,
    level_from INT NOT NULL,
    level_to INT NOT NULL,
    fragments_required INT NOT NULL,
    gold_cost INT NOT NULL
);

-- USER CARDS
CREATE TABLE IF NOT EXISTS public.user_cards (
    user_id UUID REFERENCES public.players(user_id) ON DELETE CASCADE,
    card_id TEXT REFERENCES public.card_catalog(card_id),
    obtained BOOLEAN DEFAULT FALSE,
    level INT DEFAULT 1 CHECK (level >= 1),
    fragments_owned INT DEFAULT 0 CHECK (fragments_owned >= 0),
    parts_owned INT DEFAULT 0 CHECK (parts_owned >= 0),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, card_id)
);

-- CHEST CATALOG
CREATE TABLE IF NOT EXISTS public.chest_catalog (
    chest_type TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    open_seconds INT NOT NULL,
    rewards_config_json JSONB NOT NULL,
    drop_table_id TEXT,
    enabled BOOLEAN DEFAULT TRUE
);

-- DROP TABLES
CREATE TABLE IF NOT EXISTS public.drop_tables (
    drop_table_id TEXT PRIMARY KEY,
    description TEXT
);

CREATE TABLE IF NOT EXISTS public.drop_table_entries (
    id SERIAL PRIMARY KEY,
    drop_table_id TEXT REFERENCES public.drop_tables(drop_table_id) ON DELETE CASCADE,
    item_type TEXT NOT NULL, -- 'card', 'currency', 'resource'
    item_id TEXT NOT NULL, -- card_id or 'gold' or 'random'
    min_quantity INT DEFAULT 1,
    max_quantity INT DEFAULT 1,
    weight INT DEFAULT 100,
    rarity_filter card_rarity -- Optional: if item_type='card' and item_id='random'
);

-- USER CHESTS
CREATE TABLE IF NOT EXISTS public.user_chests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.players(user_id) ON DELETE CASCADE,
    chest_type TEXT REFERENCES public.chest_catalog(chest_type),
    state chest_state DEFAULT 'locked',
    unlock_started_at TIMESTAMPTZ,
    unlock_finished_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- SHOP ITEMS
CREATE TABLE IF NOT EXISTS public.shop_items (
    shop_item_id TEXT PRIMARY KEY,
    sku TEXT,
    title TEXT NOT NULL,
    price_runes INT,
    price_gold INT,
    item_type TEXT NOT NULL,
    payload_json JSONB NOT NULL,
    enabled BOOLEAN DEFAULT TRUE
);

-- SEASON PASS
CREATE TABLE IF NOT EXISTS public.season_pass (
    season_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    rewards_track_json JSONB NOT NULL,
    premium_rewards_track_json JSONB NOT NULL,
    is_active BOOLEAN DEFAULT FALSE
);

-- USER SEASON PASS
CREATE TABLE IF NOT EXISTS public.user_season_pass (
    user_id UUID REFERENCES public.players(user_id) ON DELETE CASCADE,
    season_id UUID REFERENCES public.season_pass(season_id),
    tier INT DEFAULT 0,
    is_premium BOOLEAN DEFAULT FALSE,
    claimed_tiers_json JSONB DEFAULT '[]'::JSONB,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, season_id)
);

-- EVENTS CATALOG
CREATE TABLE IF NOT EXISTS public.events_catalog (
    event_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    config_json JSONB,
    rewards_json JSONB
);

-- USER EVENT PROGRESS
CREATE TABLE IF NOT EXISTS public.user_event_progress (
    user_id UUID REFERENCES public.players(user_id) ON DELETE CASCADE,
    event_id TEXT REFERENCES public.events_catalog(event_id),
    score INT DEFAULT 0,
    rewards_claimed_json JSONB DEFAULT '[]'::JSONB,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, event_id)
);

-- REWARD LEDGER
CREATE TABLE IF NOT EXISTS public.reward_ledger (
    ledger_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.players(user_id) ON DELETE CASCADE,
    source_type TEXT NOT NULL,
    source_id TEXT,
    rewards_json JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- REWARD OUTBOX
CREATE TABLE IF NOT EXISTS public.reward_outbox (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.players(user_id) ON DELETE CASCADE,
    ledger_id UUID REFERENCES public.reward_ledger(ledger_id),
    rewards_json JSONB NOT NULL,
    consumed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- 2.1 ENSURE COLUMNS & CONSTRAINTS EXIST (Migrations)
-- ------------------------------------------------------------------------------

DO $$ BEGIN
    ALTER TABLE public.card_catalog ADD COLUMN IF NOT EXISTS is_premium_acquisition BOOLEAN DEFAULT FALSE;
    ALTER TABLE public.card_catalog ADD COLUMN IF NOT EXISTS unlock_parts_required INT DEFAULT 6;
EXCEPTION WHEN OTHERS THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE public.card_assets ADD COLUMN IF NOT EXISTS image_url TEXT;
    ALTER TABLE public.card_assets ADD COLUMN IF NOT EXISTS model_url TEXT;
    ALTER TABLE public.card_assets ADD COLUMN IF NOT EXISTS icon_url TEXT;
    ALTER TABLE public.card_assets ADD COLUMN IF NOT EXISTS vfx_config_json JSONB;
    ALTER TABLE public.card_assets ADD COLUMN IF NOT EXISTS art_url TEXT;
    ALTER TABLE public.card_assets ADD COLUMN IF NOT EXISTS frame_variant TEXT DEFAULT 'default';
    ALTER TABLE public.card_assets ADD COLUMN IF NOT EXISTS sprite_sheet_url TEXT;
EXCEPTION WHEN OTHERS THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE public.chest_catalog ADD COLUMN IF NOT EXISTS drop_table_id TEXT REFERENCES public.drop_tables(drop_table_id);
EXCEPTION WHEN OTHERS THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE public.card_balance_profile ADD COLUMN IF NOT EXISTS range FLOAT;
    ALTER TABLE public.card_balance_profile ADD COLUMN IF NOT EXISTS is_placeholder BOOLEAN DEFAULT FALSE;
EXCEPTION WHEN OTHERS THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE public.user_cards ADD COLUMN IF NOT EXISTS parts_owned INT DEFAULT 0 CHECK (parts_owned >= 0);
EXCEPTION WHEN OTHERS THEN NULL; END $$;

-- Ensure Unique Constraints for Upserts (Force Drop and Recreate to be sure)
DO $$ BEGIN
    ALTER TABLE public.card_upgrade_requirements DROP CONSTRAINT IF EXISTS card_upgrade_requirements_rarity_level_from_key;
    ALTER TABLE public.card_upgrade_requirements ADD CONSTRAINT card_upgrade_requirements_rarity_level_from_key UNIQUE (rarity, level_from);
EXCEPTION WHEN OTHERS THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE public.card_balance_profile DROP CONSTRAINT IF EXISTS card_balance_profile_card_id_level_key;
    ALTER TABLE public.card_balance_profile ADD CONSTRAINT card_balance_profile_card_id_level_key UNIQUE (card_id, level);
EXCEPTION WHEN OTHERS THEN NULL; END $$;

-- ------------------------------------------------------------------------------
-- 3. INDEXES & RLS (Failsafe)
-- ------------------------------------------------------------------------------

CREATE INDEX IF NOT EXISTS idx_user_cards_user ON public.user_cards(user_id);
CREATE INDEX IF NOT EXISTS idx_user_chests_user ON public.user_chests(user_id);
CREATE INDEX IF NOT EXISTS idx_reward_outbox_user_consumed ON public.reward_outbox(user_id, consumed);

ALTER TABLE public.players ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_chests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_ledger ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_outbox ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_season_pass ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_event_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_catalog ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_balance_profile ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_upgrade_requirements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chest_catalog ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shop_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.season_pass ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events_catalog ENABLE ROW LEVEL SECURITY;

-- RLS Policies (Drop before Create)

-- Players
DROP POLICY IF EXISTS "Users view own profile" ON public.players;
CREATE POLICY "Users view own profile" ON public.players FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users update own profile" ON public.players;
CREATE POLICY "Users update own profile" ON public.players FOR UPDATE USING (auth.uid() = user_id);

-- User Cards
DROP POLICY IF EXISTS "Users view own cards" ON public.user_cards;
CREATE POLICY "Users view own cards" ON public.user_cards FOR SELECT USING (auth.uid() = user_id);

-- User Chests
DROP POLICY IF EXISTS "Users view own chests" ON public.user_chests;
CREATE POLICY "Users view own chests" ON public.user_chests FOR SELECT USING (auth.uid() = user_id);

-- Ledger
DROP POLICY IF EXISTS "Users view own ledger" ON public.reward_ledger;
CREATE POLICY "Users view own ledger" ON public.reward_ledger FOR SELECT USING (auth.uid() = user_id);

-- Outbox
DROP POLICY IF EXISTS "Users view/update own outbox" ON public.reward_outbox;
CREATE POLICY "Users view/update own outbox" ON public.reward_outbox FOR ALL USING (auth.uid() = user_id);

-- Season Pass
DROP POLICY IF EXISTS "Users view own season pass" ON public.user_season_pass;
CREATE POLICY "Users view own season pass" ON public.user_season_pass FOR SELECT USING (auth.uid() = user_id);

-- Event Progress
DROP POLICY IF EXISTS "Users view own event progress" ON public.user_event_progress;
CREATE POLICY "Users view own event progress" ON public.user_event_progress FOR SELECT USING (auth.uid() = user_id);

-- Public Catalogs (Read Only)
DROP POLICY IF EXISTS "Public view card catalog" ON public.card_catalog;
CREATE POLICY "Public view card catalog" ON public.card_catalog FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public view card assets" ON public.card_assets;
CREATE POLICY "Public view card assets" ON public.card_assets FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public view card balance" ON public.card_balance_profile;
CREATE POLICY "Public view card balance" ON public.card_balance_profile FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public view upgrades" ON public.card_upgrade_requirements;
CREATE POLICY "Public view upgrades" ON public.card_upgrade_requirements FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public view chest catalog" ON public.chest_catalog;
CREATE POLICY "Public view chest catalog" ON public.chest_catalog FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public view shop" ON public.shop_items;
CREATE POLICY "Public view shop" ON public.shop_items FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public view season pass" ON public.season_pass;
CREATE POLICY "Public view season pass" ON public.season_pass FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public view events" ON public.events_catalog;
CREATE POLICY "Public view events" ON public.events_catalog FOR SELECT USING (true);

-- ------------------------------------------------------------------------------
-- 4. VIEWS (Replace)
-- ------------------------------------------------------------------------------

CREATE OR REPLACE VIEW public.player_profile_view AS
SELECT 
    p.*,
    (SELECT count(*) FROM public.user_cards uc WHERE uc.user_id = p.user_id AND uc.obtained = TRUE) as cards_collected
FROM public.players p;

CREATE OR REPLACE VIEW public.user_cards_view AS
SELECT 
    cc.card_id,
    cc.name,
    cc.rarity,
    cc.type,
    cc.unlock_parts_required,
    COALESCE(uc.obtained, FALSE) as obtained,
    COALESCE(uc.level, 1) as level,
    COALESCE(uc.fragments_owned, 0) as fragments,
    COALESCE(uc.parts_owned, 0) as parts,
    ca.image_url,
    ca.icon_url
FROM public.card_catalog cc
LEFT JOIN public.user_cards uc ON cc.card_id = uc.card_id AND uc.user_id = auth.uid()
LEFT JOIN public.card_assets ca ON cc.card_id = ca.card_id;

CREATE OR REPLACE VIEW public.user_chests_view AS
SELECT 
    uc.*,
    cc.name as chest_name,
    cc.open_seconds
FROM public.user_chests uc
JOIN public.chest_catalog cc ON uc.chest_type = cc.chest_type
WHERE uc.user_id = auth.uid();

-- ------------------------------------------------------------------------------
-- 5. FUNCTIONS (RPCs)
-- ------------------------------------------------------------------------------

-- Helper: Grant Rewards
CREATE OR REPLACE FUNCTION public._internal_grant_rewards(
    p_user_id UUID,
    p_rewards JSONB,
    p_source_type TEXT,
    p_source_id TEXT
) RETURNS UUID AS $$
DECLARE
    v_ledger_id UUID;
    r JSONB;
    v_card_id TEXT;
    v_amount INT;
    v_obtained BOOLEAN;
    v_parts_owned INT;
    v_parts_req INT;
    v_existing_ledger UUID;
BEGIN
    -- 1. Idempotency Check
    SELECT ledger_id INTO v_existing_ledger 
    FROM public.reward_ledger 
    WHERE user_id = p_user_id AND source_type = p_source_type AND source_id = p_source_id
    LIMIT 1;

    IF v_existing_ledger IS NOT NULL THEN
        RETURN v_existing_ledger;
    END IF;

    -- 2. Create Ledger Entry
    INSERT INTO public.reward_ledger (user_id, source_type, source_id, rewards_json)
    VALUES (p_user_id, p_source_type, p_source_id, p_rewards)
    RETURNING ledger_id INTO v_ledger_id;

    -- 3. Add to Outbox (for UI animation)
    INSERT INTO public.reward_outbox (user_id, ledger_id, rewards_json)
    VALUES (p_user_id, v_ledger_id, p_rewards);

    -- 4. Process Rewards
    FOR r IN SELECT * FROM jsonb_array_elements(p_rewards)
    LOOP
        IF r->>'type' = 'currency' THEN
            IF r->>'id' = 'gold' THEN
                UPDATE public.players SET gold = gold + (r->>'amount')::INT WHERE user_id = p_user_id;
            ELSIF r->>'id' = 'runes' THEN
                UPDATE public.players SET runes = runes + (r->>'amount')::INT WHERE user_id = p_user_id;
            ELSIF r->>'id' = 'trophies' THEN
                UPDATE public.players SET trophies = trophies + (r->>'amount')::INT WHERE user_id = p_user_id;
            END IF;
        
        ELSIF r->>'type' = 'card_part' THEN
            v_card_id := r->>'card_id';
            v_amount := (r->>'amount')::INT;
            
            -- Ensure record exists
            INSERT INTO public.user_cards (user_id, card_id, parts_owned, obtained)
            VALUES (p_user_id, v_card_id, 0, FALSE)
            ON CONFLICT (user_id, card_id) DO NOTHING;

            SELECT obtained, parts_owned INTO v_obtained, v_parts_owned 
            FROM public.user_cards WHERE user_id = p_user_id AND card_id = v_card_id;
            
            IF v_obtained THEN
                -- Fallback: convert parts to fragments if already obtained
                UPDATE public.user_cards SET fragments_owned = fragments_owned + v_amount 
                WHERE user_id = p_user_id AND card_id = v_card_id;
            ELSE
                -- Add parts
                UPDATE public.user_cards SET parts_owned = parts_owned + v_amount 
                WHERE user_id = p_user_id AND card_id = v_card_id
                RETURNING parts_owned INTO v_parts_owned;

                -- Check for Unlock
                SELECT unlock_parts_required INTO v_parts_req 
                FROM public.card_catalog WHERE card_id = v_card_id;

                IF v_parts_owned >= v_parts_req THEN
                    -- Unlock!
                    UPDATE public.user_cards 
                    SET obtained = TRUE, 
                        parts_owned = parts_owned - v_parts_req
                    WHERE user_id = p_user_id AND card_id = v_card_id;
                END IF;
            END IF;

        ELSIF r->>'type' = 'card_fragment' THEN
            v_card_id := r->>'card_id';
            v_amount := (r->>'amount')::INT;
            
            INSERT INTO public.user_cards (user_id, card_id, fragments_owned, obtained)
            VALUES (p_user_id, v_card_id, v_amount, TRUE)
            ON CONFLICT (user_id, card_id) DO UPDATE
            SET fragments_owned = user_cards.fragments_owned + v_amount;
        END IF;
    END LOOP;

    RETURN v_ledger_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC: Grant Rewards (Admin)
CREATE OR REPLACE FUNCTION public.grant_rewards(rewards_json JSONB, source_type TEXT, source_id TEXT) 
RETURNS UUID AS $$
BEGIN
    RETURN public._internal_grant_rewards(auth.uid(), rewards_json, source_type, source_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC: Apply Card Parts
CREATE OR REPLACE FUNCTION public.apply_card_parts(
    p_card_id TEXT,
    p_parts_delta INT,
    p_source_id TEXT
) RETURNS UUID AS $$
DECLARE
    v_rewards JSONB;
BEGIN
    v_rewards := jsonb_build_array(
        jsonb_build_object('type', 'card_part', 'card_id', p_card_id, 'amount', p_parts_delta)
    );
    RETURN public._internal_grant_rewards(auth.uid(), v_rewards, 'parts_grant', p_source_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC: Unlock Card
CREATE OR REPLACE FUNCTION public.unlock_card_if_ready(card_id TEXT) RETURNS BOOLEAN AS $$
DECLARE
    v_parts INT;
    v_req INT;
    v_obtained BOOLEAN;
BEGIN
    SELECT parts_owned, obtained INTO v_parts, v_obtained
    FROM public.user_cards 
    WHERE user_id = auth.uid() AND card_id = unlock_card_if_ready.card_id;

    IF v_obtained THEN RETURN FALSE; END IF;

    SELECT unlock_parts_required INTO v_req
    FROM public.card_catalog
    WHERE card_id = unlock_card_if_ready.card_id;

    IF v_parts >= v_req THEN
        UPDATE public.user_cards
        SET obtained = TRUE, parts_owned = parts_owned - v_req
        WHERE user_id = auth.uid() AND card_id = unlock_card_if_ready.card_id;
        RETURN TRUE;
    END IF;

    RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC: Upgrade Card
CREATE OR REPLACE FUNCTION public.upgrade_card(card_id TEXT) RETURNS BOOLEAN AS $$
DECLARE
    v_current_level INT;
    v_fragments INT;
    v_rarity card_rarity;
    v_cost INT;
    v_req_fragments INT;
    v_user_gold BIGINT;
BEGIN
    SELECT level, fragments_owned INTO v_current_level, v_fragments
    FROM public.user_cards
    WHERE user_id = auth.uid() AND card_id = upgrade_card.card_id AND obtained = TRUE;

    IF v_current_level IS NULL THEN RAISE EXCEPTION 'Card not found or not obtained'; END IF;

    SELECT rarity INTO v_rarity FROM public.card_catalog WHERE card_id = upgrade_card.card_id;

    SELECT gold_cost, fragments_required INTO v_cost, v_req_fragments
    FROM public.card_upgrade_requirements
    WHERE rarity = v_rarity AND level_from = v_current_level;

    IF v_cost IS NULL THEN RAISE EXCEPTION 'Max level reached'; END IF;

    SELECT gold INTO v_user_gold FROM public.players WHERE user_id = auth.uid();

    IF v_user_gold < v_cost THEN RAISE EXCEPTION 'Not enough gold'; END IF;
    IF v_fragments < v_req_fragments THEN RAISE EXCEPTION 'Not enough fragments'; END IF;

    UPDATE public.players SET gold = gold - v_cost WHERE user_id = auth.uid();
    UPDATE public.user_cards 
    SET level = level + 1, fragments_owned = fragments_owned - v_req_fragments
    WHERE user_id = auth.uid() AND card_id = upgrade_card.card_id;

    INSERT INTO public.reward_ledger (user_id, source_type, source_id, rewards_json)
    VALUES (auth.uid(), 'upgrade', upgrade_card.card_id, jsonb_build_array(
        jsonb_build_object('type', 'currency', 'id', 'gold', 'amount', -v_cost),
        jsonb_build_object('type', 'card_fragment', 'card_id', upgrade_card.card_id, 'amount', -v_req_fragments)
    ));

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC: Purchase Shop Item
CREATE OR REPLACE FUNCTION public.purchase_shop_item(shop_item_id TEXT) RETURNS UUID AS $$
DECLARE
    v_item RECORD;
    v_user_runes BIGINT;
    v_user_gold BIGINT;
BEGIN
    SELECT * INTO v_item FROM public.shop_items WHERE shop_items.shop_item_id = purchase_shop_item.shop_item_id;
    IF v_item IS NULL THEN RAISE EXCEPTION 'Item not found'; END IF;

    IF v_item.price_runes IS NOT NULL THEN
        SELECT runes INTO v_user_runes FROM public.players WHERE user_id = auth.uid();
        IF v_user_runes < v_item.price_runes THEN RAISE EXCEPTION 'Not enough runes'; END IF;
        UPDATE public.players SET runes = runes - v_item.price_runes WHERE user_id = auth.uid();
    ELSIF v_item.price_gold IS NOT NULL THEN
        SELECT gold INTO v_user_gold FROM public.players WHERE user_id = auth.uid();
        IF v_user_gold < v_item.price_gold THEN RAISE EXCEPTION 'Not enough gold'; END IF;
        UPDATE public.players SET gold = gold - v_item.price_gold WHERE user_id = auth.uid();
    END IF;

    RETURN public._internal_grant_rewards(auth.uid(), v_item.payload_json, 'shop', shop_item_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC: Open Chest
CREATE OR REPLACE FUNCTION public.open_chest(user_chest_id UUID) RETURNS UUID AS $$
DECLARE
    v_chest RECORD;
    v_config JSONB;
    v_rewards JSONB := '[]'::JSONB;
    v_gold INT;
    v_cards_count INT;
    v_card_id TEXT;
    i INT;
BEGIN
    SELECT uc.*, cc.rewards_config_json 
    INTO v_chest 
    FROM public.user_chests uc
    JOIN public.chest_catalog cc ON uc.chest_type = cc.chest_type
    WHERE uc.id = user_chest_id AND uc.user_id = auth.uid();

    IF v_chest IS NULL THEN RAISE EXCEPTION 'Chest not found'; END IF;
    IF v_chest.state != 'ready' THEN RAISE EXCEPTION 'Chest not ready'; END IF;

    v_config := v_chest.rewards_config_json;

    v_gold := (v_config->>'min_gold')::INT + floor(random() * ((v_config->>'max_gold')::INT - (v_config->>'min_gold')::INT + 1));
    v_rewards := v_rewards || jsonb_build_object('type', 'currency', 'id', 'gold', 'amount', v_gold);

    v_cards_count := (v_config->>'total_cards')::INT;
    
    FOR i IN 1..v_cards_count LOOP
        SELECT card_id INTO v_card_id FROM public.card_catalog ORDER BY random() LIMIT 1;
        v_rewards := v_rewards || jsonb_build_object('type', 'card_fragment', 'card_id', v_card_id, 'amount', 1);
    END LOOP;

    UPDATE public.user_chests SET state = 'opened', unlock_finished_at = NOW() WHERE id = user_chest_id;

    RETURN public._internal_grant_rewards(auth.uid(), v_rewards, 'chest', user_chest_id::TEXT);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC: Create Card From Payload (Data-Driven Pipeline)
CREATE OR REPLACE FUNCTION public.create_card_from_payload(payload JSONB) RETURNS TEXT AS $$
DECLARE
    v_slug TEXT;
    v_card_id TEXT;
    v_rarity card_rarity;
    v_type card_type;
BEGIN
    v_slug := payload->>'slug';
    v_card_id := v_slug; -- Use slug as ID

    -- Validations
    IF EXISTS (SELECT 1 FROM public.card_catalog WHERE card_id = v_card_id) THEN
        RAISE EXCEPTION 'Card with slug % already exists', v_slug;
    END IF;

    v_rarity := (payload->>'rarity')::card_rarity;
    v_type := (payload->>'type')::card_type;

    -- 1. Card Catalog
    INSERT INTO public.card_catalog (
        card_id, slug, name, rarity, type, 
        is_premium_acquisition, unlock_parts_required
    ) VALUES (
        v_card_id, 
        v_slug, 
        payload->>'name', 
        v_rarity, 
        v_type,
        COALESCE((payload->>'premium_acquisition')::BOOLEAN, FALSE),
        COALESCE((payload->>'unlock_parts_required')::INT, 6)
    );

    -- 2. Card Assets
    INSERT INTO public.card_assets (
        card_id, art_url, frame_variant, sprite_sheet_url
    ) VALUES (
        v_card_id,
        payload->>'art_url',
        COALESCE(payload->>'frame_variant', 'default'),
        payload->>'sprite_sheet_url'
    );

    -- 3. Card Balance Profile (Placeholder Level 1)
    INSERT INTO public.card_balance_profile (
        card_id, level, hp, damage, speed, attack_speed, range, is_placeholder
    ) VALUES (
        v_card_id,
        1,
        COALESCE((payload->>'base_hp')::INT, 100),
        COALESCE((payload->>'base_damage')::INT, 10),
        COALESCE((payload->>'speed')::FLOAT, 1.0),
        COALESCE((payload->>'attack_speed')::FLOAT, 1.0),
        COALESCE((payload->>'range')::FLOAT, 1.0),
        TRUE
    );

    -- 4. Upgrade Requirements (Ensure Rarity Exists - Placeholder)
    INSERT INTO public.card_upgrade_requirements (rarity, level_from, level_to, fragments_required, gold_cost)
    VALUES (v_rarity, 1, 2, 5, 50)
    ON CONFLICT DO NOTHING;

    RETURN v_card_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ------------------------------------------------------------------------------
-- 6. SEED DATA (Upsert)
-- ------------------------------------------------------------------------------

-- Upgrade Costs
INSERT INTO public.card_upgrade_requirements (rarity, level_from, level_to, fragments_required, gold_cost)
VALUES
    ('common', 1, 2, 5, 50),
    ('common', 2, 3, 10, 150),
    ('rare', 1, 2, 2, 100),
    ('rare', 2, 3, 5, 300),
    ('epic', 1, 2, 1, 500),
    ('legendary', 1, 2, 1, 2000)
ON CONFLICT (rarity, level_from) DO UPDATE SET
    fragments_required = EXCLUDED.fragments_required,
    gold_cost = EXCLUDED.gold_cost;

-- Chests
INSERT INTO public.chest_catalog (chest_type, name, open_seconds, rewards_config_json, drop_table_id) VALUES
('wooden', 'Baú de Madeira', 10800, '{"min_gold": 50, "max_gold": 100, "total_cards": 5}', 'dt_chest_wooden'),
('iron', 'Baú de Ferro', 28800, '{"min_gold": 150, "max_gold": 300, "total_cards": 15}', 'dt_chest_iron'),
('runic', 'Baú Rúnico', 43200, '{"min_gold": 400, "max_gold": 800, "total_cards": 30}', 'dt_chest_runic'),
('legendary', 'Baú Lendário', 86400, '{"min_gold": 2000, "max_gold": 5000, "total_cards": 1}', 'dt_chest_legendary')
ON CONFLICT (chest_type) DO UPDATE SET
    name = EXCLUDED.name,
    open_seconds = EXCLUDED.open_seconds,
    rewards_config_json = EXCLUDED.rewards_config_json,
    drop_table_id = EXCLUDED.drop_table_id;

-- Drop Tables Seed
INSERT INTO public.drop_tables (drop_table_id, description) VALUES
('dt_chest_wooden', 'Baú de Madeira - Comum'),
('dt_chest_iron', 'Baú de Ferro - Raro'),
('dt_chest_runic', 'Baú Rúnico - Épico'),
('dt_chest_legendary', 'Baú Lendário - Lendário'),
('dt_premium_parts', 'Partes Premium (Thor/Odyn/Freya)')
ON CONFLICT (drop_table_id) DO NOTHING;

INSERT INTO public.drop_table_entries (drop_table_id, item_type, item_id, min_quantity, max_quantity, weight, rarity_filter) VALUES
-- Wooden
('dt_chest_wooden', 'card_fragment', 'random', 1, 3, 100, 'common'),
-- Iron
('dt_chest_iron', 'card_fragment', 'random', 2, 5, 90, 'common'),
('dt_chest_iron', 'card_fragment', 'random', 1, 2, 10, 'rare'),
-- Runic
('dt_chest_runic', 'card_fragment', 'random', 5, 10, 80, 'rare'),
('dt_chest_runic', 'card_fragment', 'random', 1, 3, 20, 'epic'),
-- Legendary
('dt_chest_legendary', 'card_fragment', 'random', 1, 1, 100, 'legendary'),
-- Premium Parts
('dt_premium_parts', 'card_part', 'thor', 1, 1, 33, NULL),
('dt_premium_parts', 'card_part', 'odyn', 1, 1, 33, NULL),
('dt_premium_parts', 'card_part', 'freya', 1, 1, 34, NULL);

-- Shop
INSERT INTO public.shop_items (shop_item_id, title, price_runes, item_type, payload_json) VALUES
('daily_gold', 'Ouro Diário', 0, 'currency', '[{"type": "currency", "id": "gold", "amount": 100}]'),
('small_pouch', 'Bolsa de Ouro', 50, 'currency', '[{"type": "currency", "id": "gold", "amount": 1000}]')
ON CONFLICT (shop_item_id) DO UPDATE SET
    title = EXCLUDED.title,
    price_runes = EXCLUDED.price_runes,
    payload_json = EXCLUDED.payload_json;

-- Cards
INSERT INTO public.card_catalog (card_id, slug, name, rarity, type, is_premium_acquisition, unlock_parts_required) VALUES
('thor', 'thor', 'Thor', 'legendary', 'troop', TRUE, 10),
('odyn', 'odyn', 'Odyn', 'legendary', 'troop', TRUE, 10),
('freya', 'freya', 'Freya', 'legendary', 'troop', TRUE, 10),
('archer', 'archer', 'Arqueira', 'common', 'troop', FALSE, 6)
ON CONFLICT (card_id) DO UPDATE SET 
    is_premium_acquisition = EXCLUDED.is_premium_acquisition,
    unlock_parts_required = EXCLUDED.unlock_parts_required;
