-- -----------------------------------------------------------------------------
-- View: v_player_summary
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.v_player_summary AS
SELECT 
    p.id,
    p.nickname,
    p.level,
    p.trophies,
    p.current_arena_id,
    a.name as arena_name,
    (SELECT count(*) FROM public.user_cards uc WHERE uc.user_id = p.id AND uc.is_obtained = true) as cards_collected
FROM public.profiles p
LEFT JOIN public.arenas a ON p.current_arena_id = a.id;

-- -----------------------------------------------------------------------------
-- Integrity Checks
-- -----------------------------------------------------------------------------
-- Ensure deck size doesn't exceed 8 (though app logic enforces 4-8, DB constraint is good)
ALTER TABLE public.deck_cards
ADD CONSTRAINT deck_size_limit CHECK (position >= 0 AND position < 8);

-- Ensure currency is never negative
ALTER TABLE public.profiles
ADD CONSTRAINT positive_coins CHECK (coins >= 0),
ADD CONSTRAINT positive_rubies CHECK (rubies >= 0),
ADD CONSTRAINT positive_runes CHECK (runes >= 0);
