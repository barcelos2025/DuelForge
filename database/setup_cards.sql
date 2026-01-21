-- 1. Create Table
CREATE TABLE IF NOT EXISTS public.cards (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('unit', 'spell', 'building')),
    rarity TEXT NOT NULL CHECK (rarity IN ('common', 'rare', 'epic', 'legendary')),
    cost INT NOT NULL DEFAULT 1,
    base_stats JSONB NOT NULL DEFAULT '{}'::jsonb,
    asset_path TEXT,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Enable RLS
ALTER TABLE public.cards ENABLE ROW LEVEL SECURITY;

-- 3. Create Policy (Public Read)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_policies 
        WHERE tablename = 'cards' 
        AND policyname = 'Cards are viewable by everyone'
    ) THEN
        CREATE POLICY "Cards are viewable by everyone" ON public.cards FOR SELECT USING (true);
    END IF;
END $$;

-- 4. Seed Data
INSERT INTO public.cards (id, name, type, rarity, cost, asset_path, base_stats) VALUES
('escudeiro_carvalho', 'Escudeiro de Carvalho', 'unit', 'common', 2, 'assets/cards/df_card_shield_warrior_v01.jpg', '{"poder": 3, "hp": 260, "dano": 28, "velocidade": 55, "alcance": 10, "alvo": "terrestre", "notas": "mini-tanque"}'::jsonb),
('arqueira_fiorde', 'Arqueira do Fiorde', 'unit', 'common', 2, 'assets/cards/df_card_frost_ranger_v01.jpg', '{"poder": 3, "hp": 160, "dano": 36, "velocidade": 65, "alcance": 140, "alvo": "terrestre", "notas": "DPS à distância"}'::jsonb),
('berserker_tundra', 'Berserker da Tundra', 'unit', 'common', 3, 'assets/cards/df_card_bear_berserker_v01.jpg', '{"poder": 4, "hp": 190, "dano": 50, "velocidade": 80, "alcance": 10, "alvo": "terrestre", "notas": "agressivo"}'::jsonb),
('barricada_troncos', 'Barricada de Troncos', 'building', 'common', 2, 'assets/cards/df_card_palisade_wall_v01.jpg', '{"poder": 2, "hp": 260, "duracao": 14, "alcance": 0, "notas": "segura rota"}'::jsonb),
('veneno', 'Veneno', 'spell', 'rare', 4, 'assets/cards/df_card_poison_v01.png', '{"poder": 6, "raio": 120, "duracao": 6, "dps": 22, "efeito": "dano_area"}'::jsonb),
('chuva_granizo', 'Chuva de Granizo', 'spell', 'rare', 3, 'assets/cards/df_card_hailstorm_v01.png', '{"poder": 5, "raio": 120, "duracao": 4, "dps": 14, "slow": 0.35, "efeito": "dano_area_slow"}'::jsonb),
('nuvem_raios', 'Nuvem de Raios', 'spell', 'epic', 6, 'assets/cards/df_card_lightning_cloud_v01.png', '{"poder": 8, "saltos": 3, "dano": 90, "efeito": "cadeia"}'::jsonb),
('boneco_voodoo', 'Boneco Voodoo', 'spell', 'epic', 5, 'assets/cards/df_card_voodoo_doll_v01.png', '{"poder": 7, "duracao": 7, "link_pct": 0.35, "efeito": "link_dano"}'::jsonb),
('axe_commander', 'Comandante do Machado', 'unit', 'rare', 4, 'assets/cards/df_card_axe_commander_v01.jpg', '{"poder": 5, "hp": 400, "dano": 60, "velocidade": 50, "alcance": 10, "alvo": "terrestre"}'::jsonb),
('brynhild', 'Brynhild', 'unit', 'legendary', 5, 'assets/cards/df_card_brynhild_v01.jpg', '{"poder": 8, "hp": 600, "dano": 85, "velocidade": 60, "alcance": 10, "alvo": "terrestre"}'::jsonb),
('catapulta', 'Catapulta', 'building', 'rare', 4, 'assets/cards/df_card_catapult_v0.png', '{"poder": 4, "hp": 350, "duracao": 20, "alcance": 300, "dano": 40}'::jsonb),
('catapulta_fogo', 'Catapulta de Fogo', 'building', 'epic', 5, 'assets/cards/df_card_fire_catapult_v01.png', '{"poder": 6, "hp": 400, "duracao": 20, "alcance": 300, "dano": 60, "efeito": "dano_area"}'::jsonb),
('freyja', 'Freyja', 'unit', 'legendary', 5, 'assets/cards/df_card_freyja_v01.jpg', '{"poder": 9, "hp": 500, "dano": 70, "velocidade": 65, "alcance": 150, "alvo": "aereo_terrestre"}'::jsonb),
('portao_gelo', 'Portão de Gelo', 'building', 'common', 3, 'assets/cards/df_card_frost_gate_v01.jpg', '{"poder": 3, "hp": 500, "duracao": 25, "alcance": 0, "efeito": "slow_area"}'::jsonb),
('corredor_gelo', 'Corredor de Gelo', 'unit', 'rare', 3, 'assets/cards/df_card_ice_runner_v01.jpg', '{"poder": 4, "hp": 220, "dano": 45, "velocidade": 90, "alcance": 10, "alvo": "construcao"}'::jsonb),
('truque_loki', 'Truque de Loki', 'spell', 'epic', 3, 'assets/cards/df_card_loki_trickery_v01.jpg', '{"poder": 5, "duracao": 5, "efeito": "invisibilidade"}'::jsonb),
('odyn', 'Odyn', 'unit', 'legendary', 8, 'assets/cards/df_card_odyn_master_v01.jpg', '{"poder": 10, "hp": 1000, "dano": 150, "velocidade": 40, "alcance": 10, "alvo": "terrestre"}'::jsonb),
('corvos_odyn', 'Corvos de Odyn', 'unit', 'common', 2, 'assets/cards/df_card_odyn_ravens_v01.jpg', '{"poder": 2, "hp": 80, "dano": 20, "velocidade": 85, "alcance": 10, "alvo": "aereo_terrestre", "saltos": 2}'::jsonb),
('chuva_lancas', 'Chuva de Lanças', 'spell', 'common', 3, 'assets/cards/df_card_runic_spear_rain_v01.jpg', '{"poder": 3, "dano": 150, "raio": 80, "efeito": "dano_area"}'::jsonb),
('bardo', 'Bardo Skald', 'unit', 'common', 3, 'assets/cards/df_card_skald_bard_v01.jpg', '{"poder": 2, "hp": 200, "dano": 15, "velocidade": 60, "alcance": 100, "efeito": "buff_velocidade"}'::jsonb),
('thor', 'Thor', 'unit', 'legendary', 6, 'assets/cards/df_card_thor_v01.jpg', '{"poder": 9, "hp": 800, "dano": 100, "velocidade": 50, "alcance": 10, "efeito": "stun"}'::jsonb),
('martelo_trovao', 'Martelo do Trovão', 'spell', 'rare', 4, 'assets/cards/df_card_thunder_hammer_v01.jpg', '{"poder": 6, "dano": 250, "raio": 60, "efeito": "stun"}'::jsonb),
('cacadora_troll', 'Caçadora de Trolls', 'unit', 'rare', 4, 'assets/cards/df_card_troll_huntress_v01.jpg', '{"poder": 5, "hp": 300, "dano": 45, "velocidade": 70, "alcance": 160, "alvo": "aereo_terrestre"}'::jsonb),
('tyr', 'Tyr', 'unit', 'legendary', 5, 'assets/cards/df_card_tyr_v01.jpg', '{"poder": 8, "hp": 700, "dano": 90, "velocidade": 55, "alcance": 10, "alvo": "terrestre"}'::jsonb),
('ulf', 'Ulf Lendário', 'unit', 'legendary', 4, 'assets/cards/df_card_ulf_legendary_v01.jpg', '{"poder": 7, "hp": 500, "dano": 80, "velocidade": 75, "alcance": 10, "alvo": "terrestre"}'::jsonb),
('torre_vigia', 'Torre de Vigia', 'building', 'common', 3, 'assets/cards/df_card_watchtower_v01.jpg', '{"poder": 3, "hp": 400, "duracao": 30, "alcance": 250, "dano": 35}'::jsonb),
('cacador_baleia', 'Caçador de Baleias', 'unit', 'common', 3, 'assets/cards/df_card_whale_hunter_v01.jpg', '{"poder": 3, "hp": 250, "dano": 40, "velocidade": 60, "alcance": 120, "alvo": "terrestre"}'::jsonb),
('demonio_alado', 'Demônio Alado', 'unit', 'legendary', 5, 'assets/cards/df_card_winged_demon_legendary_v01.png', '{"poder": 8, "hp": 450, "dano": 75, "velocidade": 80, "alcance": 10, "alvo": "terrestre", "notas": "voador"}'::jsonb)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    type = EXCLUDED.type,
    rarity = EXCLUDED.rarity,
    cost = EXCLUDED.cost,
    asset_path = EXCLUDED.asset_path,
    base_stats = EXCLUDED.base_stats;
