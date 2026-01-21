-- -----------------------------------------------------------------------------
-- 1. CARD UPGRADE REQUIREMENTS (Global Config)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.card_upgrade_requirements (
    id SERIAL PRIMARY KEY,
    rarity TEXT NOT NULL CHECK (rarity IN ('common', 'rare', 'epic', 'legendary')),
    level_from INT NOT NULL,
    level_to INT NOT NULL,
    fragments_required INT NOT NULL,
    coins_cost INT DEFAULT 0,
    rubies_cost INT DEFAULT 0,
    is_placeholder BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE (rarity, level_from)
);

-- RLS: Public Read
ALTER TABLE public.card_upgrade_requirements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Upgrade requirements are viewable by everyone" ON public.card_upgrade_requirements FOR SELECT USING (true);

-- -----------------------------------------------------------------------------
-- 2. SEED DEFAULT REQUIREMENTS (Placeholder)
-- -----------------------------------------------------------------------------
-- Common: 1->2 (20), 2->3 (50), 3->4 (100), ... 12->13 (5000)
INSERT INTO public.card_upgrade_requirements (rarity, level_from, level_to, fragments_required, coins_cost)
VALUES
    ('common', 1, 2, 20, 50),
    ('common', 2, 3, 50, 150),
    ('common', 3, 4, 100, 400),
    ('common', 4, 5, 200, 1000),
    ('common', 5, 6, 400, 2000),
    ('common', 6, 7, 800, 4000),
    ('common', 7, 8, 1000, 8000),
    ('common', 8, 9, 2000, 16000),
    ('common', 9, 10, 4000, 32000),
    ('common', 10, 11, 5000, 50000),
    ('common', 11, 12, 8000, 100000),
    ('common', 12, 13, 10000, 100000) -- Max level cap?
ON CONFLICT (rarity, level_from) DO NOTHING;

-- Rare: Starts higher? Or same curve but fewer cards? Let's assume standard mobile game curve
INSERT INTO public.card_upgrade_requirements (rarity, level_from, level_to, fragments_required, coins_cost)
VALUES
    ('rare', 1, 2, 10, 200),
    ('rare', 2, 3, 20, 1000),
    ('rare', 3, 4, 50, 4000),
    ('rare', 4, 5, 100, 10000),
    ('rare', 5, 6, 200, 20000),
    ('rare', 6, 7, 400, 50000),
    ('rare', 7, 8, 800, 100000),
    ('rare', 8, 9, 1000, 100000)
ON CONFLICT (rarity, level_from) DO NOTHING;

-- Epic
INSERT INTO public.card_upgrade_requirements (rarity, level_from, level_to, fragments_required, coins_cost)
VALUES
    ('epic', 1, 2, 2, 1000),
    ('epic', 2, 3, 5, 4000),
    ('epic', 3, 4, 10, 10000),
    ('epic', 4, 5, 20, 20000),
    ('epic', 5, 6, 50, 50000),
    ('epic', 6, 7, 100, 100000)
ON CONFLICT (rarity, level_from) DO NOTHING;

-- Legendary
INSERT INTO public.card_upgrade_requirements (rarity, level_from, level_to, fragments_required, coins_cost)
VALUES
    ('legendary', 1, 2, 1, 5000),
    ('legendary', 2, 3, 2, 20000),
    ('legendary', 3, 4, 4, 50000),
    ('legendary', 4, 5, 10, 100000)
ON CONFLICT (rarity, level_from) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 3. RPC: upgrade_card
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.upgrade_card(p_card_id TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID;
    v_card_rarity TEXT;
    v_current_level INT;
    v_fragments_owned INT;
    v_req_fragments INT;
    v_req_coins INT;
    v_user_coins INT;
    v_new_level INT;
BEGIN
    v_user_id := auth.uid();

    -- 1. Get User Card State & Rarity
    SELECT uc.level, uc.fragments, c.rarity
    INTO v_current_level, v_fragments_owned, v_card_rarity
    FROM public.user_cards uc
    JOIN public.cards c ON c.id = uc.card_id
    WHERE uc.user_id = v_user_id AND uc.card_id = p_card_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Card not found or not owned';
    END IF;

    -- 2. Get Upgrade Requirements
    SELECT fragments_required, coins_cost, level_to
    INTO v_req_fragments, v_req_coins, v_new_level
    FROM public.card_upgrade_requirements
    WHERE rarity = v_card_rarity AND level_from = v_current_level;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Max level reached or requirements not defined';
    END IF;

    -- 3. Validate Resources
    IF v_fragments_owned < v_req_fragments THEN
        RAISE EXCEPTION 'Not enough fragments';
    END IF;

    SELECT coins INTO v_user_coins FROM public.profiles WHERE id = v_user_id;
    IF v_user_coins < v_req_coins THEN
        RAISE EXCEPTION 'Not enough coins';
    END IF;

    -- 4. Execute Upgrade (Transactional)
    
    -- Deduct Coins
    UPDATE public.profiles
    SET coins = coins - v_req_coins, updated_at = NOW()
    WHERE id = v_user_id;

    -- Update Card (Level Up, Deduct Fragments)
    UPDATE public.user_cards
    SET 
        level = v_new_level,
        fragments = fragments - v_req_fragments,
        updated_at = NOW()
    WHERE user_id = v_user_id AND card_id = p_card_id
    RETURNING to_jsonb(user_cards.*) INTO v_current_level; -- Reusing variable for return json

    -- Log to Ledger
    INSERT INTO public.ledger (user_id, currency, amount, source, balance_after)
    VALUES (v_user_id, 'coins', -v_req_coins, 'upgrade_card:' || p_card_id, v_user_coins - v_req_coins);

    RETURN jsonb_build_object(
        'success', true,
        'new_level', v_new_level,
        'remaining_fragments', v_fragments_owned - v_req_fragments,
        'remaining_coins', v_user_coins - v_req_coins
    );
END;
$$;

-- -----------------------------------------------------------------------------
-- 4. VIEW: v_user_collection_progress
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.v_user_collection_progress AS
SELECT 
    uc.user_id,
    uc.card_id,
    c.name,
    c.rarity,
    uc.level,
    uc.fragments as fragments_owned,
    COALESCE(req.fragments_required, 0) as fragments_required,
    COALESCE(req.coins_cost, 0) as upgrade_cost,
    (uc.fragments >= req.fragments_required) as can_upgrade
FROM public.user_cards uc
JOIN public.cards c ON c.id = uc.card_id
LEFT JOIN public.card_upgrade_requirements req 
    ON req.rarity = c.rarity AND req.level_from = uc.level;
