INSERT INTO public.arenas (id, name, unlock_trophies, theme_key)
VALUES
    (1, 'Training Camp', 0, 'training'),
    (2, 'Frozen Peak', 400, 'ice'),
    (3, 'Viking Village', 800, 'viking'),
    (4, 'Crystal Cavern', 1200, 'crystal'),
    (5, 'Dragon''s Nest', 1600, 'fire'),
    (6, 'Valhalla', 2000, 'heaven')
ON CONFLICT (id) DO UPDATE 
SET name = EXCLUDED.name, 
    unlock_trophies = EXCLUDED.unlock_trophies,
    theme_key = EXCLUDED.theme_key;
