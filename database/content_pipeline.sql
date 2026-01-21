-- ==============================================================================
-- DUELFORGE: DATA-DRIVEN CONTENT PIPELINE
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. NEW TABLES FOR ASSETS & BALANCE
-- ------------------------------------------------------------------------------

-- CARD ASSETS (Visuals)
CREATE TABLE IF NOT EXISTS public.card_assets (
    card_id TEXT PRIMARY KEY REFERENCES public.card_catalog(card_id) ON DELETE CASCADE,
    art_url TEXT NOT NULL, -- Main card art
    frame_variant TEXT DEFAULT 'default', -- e.g., 'gold_border', 'winter_theme'
    sprite_sheet_url TEXT, -- In-game unit sprite
    vfx_url TEXT, -- Spawn/Attack VFX
    sound_deploy_url TEXT,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- CARD BALANCE PROFILE (Stats)
CREATE TABLE IF NOT EXISTS public.card_balance_profile (
    card_id TEXT PRIMARY KEY REFERENCES public.card_catalog(card_id) ON DELETE CASCADE,
    elixir_cost INT DEFAULT 3,
    base_hp INT DEFAULT 100,
    base_damage INT DEFAULT 50,
    attack_speed NUMERIC(4,2) DEFAULT 1.0, -- Seconds per attack
    range NUMERIC(4,2) DEFAULT 1.0, -- Tiles
    move_speed NUMERIC(4,2) DEFAULT 1.0, -- Tiles per second
    targets TEXT DEFAULT 'ground', -- 'ground', 'air', 'both', 'building'
    mechanics_json JSONB DEFAULT '{}'::JSONB, -- Special abilities (dash, stun, etc)
    is_placeholder BOOLEAN DEFAULT TRUE, -- Mark for tuning
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- DROP TABLES (Dynamic Loot)
CREATE TABLE IF NOT EXISTS public.drop_tables (
    id TEXT PRIMARY KEY, -- e.g., 'standard_chest_pool', 'arena_1_pool'
    name TEXT,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.drop_table_entries (
    id SERIAL PRIMARY KEY,
    drop_table_id TEXT REFERENCES public.drop_tables(id) ON DELETE CASCADE,
    rarity card_rarity, -- If set, picks random card of this rarity
    specific_card_id TEXT REFERENCES public.card_catalog(card_id), -- If set, picks this specific card
    weight INT DEFAULT 100, -- Probability weight
    min_qty INT DEFAULT 1,
    max_qty INT DEFAULT 1,
    enabled BOOLEAN DEFAULT TRUE,
    CONSTRAINT check_target CHECK (rarity IS NOT NULL OR specific_card_id IS NOT NULL)
);

-- ------------------------------------------------------------------------------
-- 2. UPDATES TO EXISTING TABLES
-- ------------------------------------------------------------------------------

-- Link Chests to Drop Tables
ALTER TABLE public.chest_catalog 
ADD COLUMN drop_table_id TEXT REFERENCES public.drop_tables(id);

-- Allow Card Specific Overrides in Upgrade Requirements
ALTER TABLE public.card_upgrade_requirements
ADD COLUMN card_id TEXT REFERENCES public.card_catalog(card_id);

-- Remove UNIQUE constraint to allow card overrides
ALTER TABLE public.card_upgrade_requirements DROP CONSTRAINT IF EXISTS card_upgrade_requirements_rarity_level_from_key;
-- Add new constraint: Unique per (rarity, level) UNLESS card_id is set
CREATE UNIQUE INDEX idx_upgrade_req_generic ON public.card_upgrade_requirements(rarity, level_from) WHERE card_id IS NULL;
CREATE UNIQUE INDEX idx_upgrade_req_specific ON public.card_upgrade_requirements(card_id, level_from) WHERE card_id IS NOT NULL;

-- ------------------------------------------------------------------------------
-- 3. RLS POLICIES
-- ------------------------------------------------------------------------------

ALTER TABLE public.card_assets ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public view card assets" ON public.card_assets;
CREATE POLICY "Public view card assets" ON public.card_assets FOR SELECT USING (true);

ALTER TABLE public.card_balance_profile ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public view card balance" ON public.card_balance_profile;
CREATE POLICY "Public view card balance" ON public.card_balance_profile FOR SELECT USING (true);

ALTER TABLE public.drop_tables ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.drop_table_entries ENABLE ROW LEVEL SECURITY;
-- Drop tables usually internal logic, but maybe client needs to show "Possible Rewards"
DROP POLICY IF EXISTS "Public view drop tables" ON public.drop_tables;
CREATE POLICY "Public view drop tables" ON public.drop_tables FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public view drop entries" ON public.drop_table_entries;
CREATE POLICY "Public view drop entries" ON public.drop_table_entries FOR SELECT USING (true);

-- ------------------------------------------------------------------------------
-- 4. RPC: CREATE CARD FROM PAYLOAD
-- ------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.create_card_from_payload(
    payload JSONB
) RETURNS TEXT AS $$
DECLARE
    v_slug TEXT;
    v_card_id TEXT;
    v_rarity card_rarity;
    v_type card_type;
BEGIN
    -- 1. Parse & Validate
    v_slug := payload->>'slug';
    IF v_slug IS NULL THEN RAISE EXCEPTION 'Slug is required'; END IF;
    
    -- Generate ID from slug (ensure snake_case)
    v_card_id := lower(regexp_replace(v_slug, '[^a-zA-Z0-9]', '_', 'g'));
    
    v_rarity := (payload->>'rarity')::card_rarity;
    v_type := (payload->>'type')::card_type;

    -- 2. Insert Catalog
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
    ) ON CONFLICT (card_id) DO UPDATE SET
        name = EXCLUDED.name,
        rarity = EXCLUDED.rarity,
        type = EXCLUDED.type;

    -- 3. Insert Assets
    INSERT INTO public.card_assets (card_id, art_url, sprite_sheet_url)
    VALUES (
        v_card_id,
        payload->>'art_url',
        payload->>'sprite_sheet_url'
    ) ON CONFLICT (card_id) DO UPDATE SET
        art_url = EXCLUDED.art_url,
        sprite_sheet_url = EXCLUDED.sprite_sheet_url;

    -- 4. Insert Balance Profile (Placeholders)
    INSERT INTO public.card_balance_profile (
        card_id, elixir_cost, base_hp, base_damage
    ) VALUES (
        v_card_id,
        COALESCE((payload->'stats'->>'elixir')::INT, 3),
        COALESCE((payload->'stats'->>'hp')::INT, 100),
        COALESCE((payload->'stats'->>'damage')::INT, 50)
    ) ON CONFLICT (card_id) DO NOTHING; -- Keep existing tuning if present

    -- 5. Add to Default Drop Table (Optional - e.g. 'global_pool')
    -- INSERT INTO public.drop_table_entries ...

    RETURN v_card_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ------------------------------------------------------------------------------
-- 5. VIEWS FOR CLIENT
-- ------------------------------------------------------------------------------

CREATE OR REPLACE VIEW public.view_full_card_definitions AS
SELECT 
    c.card_id,
    c.name,
    c.rarity,
    c.type,
    c.slug,
    a.art_url,
    a.sprite_sheet_url,
    b.elixir_cost,
    b.base_hp,
    b.base_damage,
    b.attack_speed,
    b.range,
    b.move_speed,
    b.targets,
    b.mechanics_json
FROM public.card_catalog c
LEFT JOIN public.card_assets a ON c.card_id = a.card_id
LEFT JOIN public.card_balance_profile b ON c.card_id = b.card_id
WHERE c.enabled = TRUE;

-- ------------------------------------------------------------------------------
-- 6. SEED DATA (Example Drop Table)
-- ------------------------------------------------------------------------------

INSERT INTO public.drop_tables (id, name) VALUES ('global_standard', 'Standard Global Pool') ON CONFLICT DO NOTHING;

-- Entry: Common Cards (Weight 1000)
INSERT INTO public.drop_table_entries (drop_table_id, rarity, weight) VALUES ('global_standard', 'common', 1000);
-- Entry: Rare Cards (Weight 200)
INSERT INTO public.drop_table_entries (drop_table_id, rarity, weight) VALUES ('global_standard', 'rare', 200);

-- Update existing chests to use this table
UPDATE public.chest_catalog SET drop_table_id = 'global_standard';

