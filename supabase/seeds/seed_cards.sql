-- Confirmed Cards
INSERT INTO public.cards (id, name, type, rarity, elixir_cost, base_stats, description)
VALUES
    ('unit_bear_berserker', 'Bear Berserker', 'unit', 'rare', 4, '{"hp": 1200, "damage": 200, "speed": 1.5, "range": 0}'::jsonb, 'A fierce warrior with the strength of a bear.'),
    ('unit_frost_ranger', 'Frost Ranger', 'unit', 'common', 3, '{"hp": 600, "damage": 120, "speed": 1.2, "range": 5.5}'::jsonb, 'Shoots freezing arrows that slow enemies.'),
    ('building_catapult', 'Catapult', 'building', 'common', 4, '{"hp": 800, "damage": 250, "speed": 0, "range": 11, "lifetime": 30}'::jsonb, 'Launches heavy stones at long range.'),
    ('building_fire_catapult', 'Fire Catapult', 'building', 'rare', 5, '{"hp": 900, "damage": 300, "speed": 0, "range": 11, "lifetime": 30}'::jsonb, 'Launches burning projectiles dealing area damage.'),
    ('unit_winged_demon', 'Winged Demon', 'unit', 'legendary', 5, '{"hp": 1500, "damage": 280, "speed": 2.0, "range": 0, "flying": true}'::jsonb, 'A terror from the skies.'),
    ('spell_lightning_cloud', 'Lightning Cloud', 'spell', 'epic', 4, '{"damage": 400, "radius": 2.5, "stun": 0.5}'::jsonb, 'Strikes enemies with lightning.'),
    ('spell_voodoo_doll', 'Voodoo Doll', 'spell', 'epic', 3, '{"duration": 5, "damage_share": 0.5}'::jsonb, 'Links enemies to share damage.'),
    ('spell_poison', 'Poison', 'spell', 'rare', 4, '{"damage_per_sec": 80, "duration": 8, "radius": 3.5}'::jsonb, 'Creates a toxic cloud that damages over time.'),
    ('spell_hailstorm', 'Hailstorm', 'spell', 'rare', 3, '{"damage": 150, "slow": 0.3, "radius": 3.0}'::jsonb, 'Rains ice shards slowing enemies.');

-- Placeholders (10-28)
INSERT INTO public.cards (id, name, type, rarity, elixir_cost, is_enabled)
VALUES
    ('card_10', 'Placeholder 10', 'unit', 'common', 3, false),
    ('card_11', 'Placeholder 11', 'unit', 'common', 3, false),
    ('card_12', 'Placeholder 12', 'unit', 'common', 3, false),
    ('card_13', 'Placeholder 13', 'unit', 'common', 3, false),
    ('card_14', 'Placeholder 14', 'unit', 'common', 3, false),
    ('card_15', 'Placeholder 15', 'unit', 'common', 3, false),
    ('card_16', 'Placeholder 16', 'unit', 'common', 3, false),
    ('card_17', 'Placeholder 17', 'unit', 'common', 3, false),
    ('card_18', 'Placeholder 18', 'unit', 'common', 3, false),
    ('card_19', 'Placeholder 19', 'unit', 'common', 3, false),
    ('card_20', 'Placeholder 20', 'unit', 'common', 3, false),
    ('card_21', 'Placeholder 21', 'unit', 'common', 3, false),
    ('card_22', 'Placeholder 22', 'unit', 'common', 3, false),
    ('card_23', 'Placeholder 23', 'unit', 'common', 3, false),
    ('card_24', 'Placeholder 24', 'unit', 'common', 3, false),
    ('card_25', 'Placeholder 25', 'unit', 'common', 3, false),
    ('card_26', 'Placeholder 26', 'unit', 'common', 3, false),
    ('card_27', 'Placeholder 27', 'unit', 'common', 3, false),
    ('card_28', 'Placeholder 28', 'unit', 'common', 3, false)
ON CONFLICT (id) DO NOTHING;
