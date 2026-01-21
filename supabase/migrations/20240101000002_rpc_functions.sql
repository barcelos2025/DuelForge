-- -----------------------------------------------------------------------------
-- RPC: claim_nickname_and_country
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.claim_nickname_and_country(
    p_nickname TEXT,
    p_country TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID;
BEGIN
    v_user_id := auth.uid();
    
    -- Validate input
    IF length(p_nickname) < 3 THEN
        RAISE EXCEPTION 'Nickname must be at least 3 characters';
    END IF;

    -- Update profile
    UPDATE public.profiles
    SET 
        nickname = p_nickname::citext,
        country_iso2 = p_country,
        updated_at = NOW()
    WHERE id = v_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Profile not found';
    END IF;

    RETURN jsonb_build_object('success', true);
EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Nickname already taken';
END;
$$;

-- -----------------------------------------------------------------------------
-- RPC: get_full_player_state
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_full_player_state()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID;
    v_profile JSONB;
    v_collection JSONB;
    v_decks JSONB;
BEGIN
    v_user_id := auth.uid();

    -- Get Profile
    SELECT to_jsonb(p) INTO v_profile
    FROM public.profiles p
    WHERE p.id = v_user_id;

    -- Get Collection
    SELECT jsonb_agg(
        jsonb_build_object(
            'card_id', uc.card_id,
            'level', uc.level,
            'fragments', uc.fragments,
            'is_obtained', uc.is_obtained
        )
    ) INTO v_collection
    FROM public.user_cards uc
    WHERE uc.user_id = v_user_id;

    -- Get Decks with Cards
    WITH deck_data AS (
        SELECT 
            d.id,
            d.name,
            d.is_active,
            (
                SELECT jsonb_agg(dc.card_id ORDER BY dc.position)
                FROM public.deck_cards dc
                WHERE dc.deck_id = d.id
            ) as cards
        FROM public.decks d
        WHERE d.user_id = v_user_id
    )
    SELECT jsonb_agg(to_jsonb(dd)) INTO v_decks FROM deck_data dd;

    RETURN jsonb_build_object(
        'profile', v_profile,
        'collection', COALESCE(v_collection, '[]'::jsonb),
        'decks', COALESCE(v_decks, '[]'::jsonb)
    );
END;
$$;

-- -----------------------------------------------------------------------------
-- RPC: ensure_player_bootstrap
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.ensure_player_bootstrap()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID;
    v_profile_exists BOOLEAN;
    v_deck_id UUID;
BEGIN
    v_user_id := auth.uid();
    
    -- Check if profile exists
    SELECT EXISTS (SELECT 1 FROM public.profiles WHERE id = v_user_id) INTO v_profile_exists;
    
    IF NOT v_profile_exists THEN
        -- Create Profile
        INSERT INTO public.profiles (id, nickname, country_iso2)
        VALUES (v_user_id, 'Player_' || substr(md5(random()::text), 1, 6), 'BR');
        
        -- Give Starter Cards (All Commons)
        INSERT INTO public.user_cards (user_id, card_id, level, fragments, is_obtained)
        SELECT v_user_id, id, 1, 0, true
        FROM public.cards
        WHERE rarity = 'common';
        
        -- Create Default Deck
        INSERT INTO public.decks (user_id, name, is_active)
        VALUES (v_user_id, 'Starter Deck', true)
        RETURNING id INTO v_deck_id;
        
        -- Add 4 starter cards to deck
        INSERT INTO public.deck_cards (deck_id, card_id, position)
        SELECT v_deck_id, id, row_number() OVER () - 1
        FROM public.cards
        WHERE rarity = 'common'
        LIMIT 4;
        
        RETURN jsonb_build_object('status', 'created', 'deck_id', v_deck_id);
    END IF;
    
    RETURN jsonb_build_object('status', 'exists');
END;
$$;
