-- ==============================================================================
-- DUELFORGE: INITIAL CONTENT BOOTSTRAP (v1.0.0)
-- ==============================================================================

DO $$
DECLARE
    v_ver UUID;
    v_cards JSONB;
    v_balance JSONB;
    v_shop JSONB;
    v_drops JSONB;
    v_events JSONB;
    v_pass JSONB;
    v_flags JSONB;
BEGIN
    -- 1. Definir Payloads (JSONs)
    
    -- Card Catalog (Exemplo com algumas cartas principais, expandir conforme necessário)
    v_cards := '[
        {"id": "archer", "name": "Arqueira", "rarity": "common", "type": "troop", "cost": 3, "description": "Atiradora versátil."},
        {"id": "knight", "name": "Cavaleiro", "rarity": "rare", "type": "troop", "cost": 4, "description": "Tanque resistente."},
        {"id": "fireball", "name": "Bola de Fogo", "rarity": "rare", "type": "spell", "cost": 4, "description": "Dano em área."},
        {"id": "giant", "name": "Gigante", "rarity": "rare", "type": "troop", "cost": 5, "description": "Foca em construções."},
        {"id": "thor", "name": "Thor", "rarity": "legendary", "type": "troop", "cost": 5, "description": "Deus do Trovão. Premium.", "is_premium": true},
        {"id": "odyn", "name": "Odyn", "rarity": "legendary", "type": "troop", "cost": 6, "description": "Pai de Todos. Premium.", "is_premium": true},
        {"id": "freya", "name": "Freya", "rarity": "legendary", "type": "troop", "cost": 4, "description": "Deusa da Guerra. Premium.", "is_premium": true}
    ]'::JSONB;

    -- Balance Rules
    v_balance := '{
        "global_damage_mult": 1.0,
        "global_hp_mult": 1.0,
        "elixir_regen_base": 0.35,
        "elixir_regen_overtime": 0.7
    }'::JSONB;

    -- Shop Config
    v_shop := '{
        "daily_refresh_hour_utc": 0,
        "slots": 6,
        "slot_types": ["daily_gift", "common_card", "rare_card", "epic_card", "gold_pouch", "gem_pouch"]
    }'::JSONB;

    -- Drop Tables (Cópia da estrutura definida anteriormente)
    v_drops := '{
        "chests": ["wooden", "iron", "runic", "legendary"],
        "tables": {
            "dt_chest_wooden": {"min_gold": 50, "max_gold": 100, "cards": 5, "guaranteed_rare": 0},
            "dt_chest_iron": {"min_gold": 150, "max_gold": 300, "cards": 15, "guaranteed_rare": 1},
            "dt_chest_runic": {"min_gold": 400, "max_gold": 800, "cards": 30, "guaranteed_rare": 10, "guaranteed_epic": 1},
            "dt_chest_legendary": {"min_gold": 2000, "max_gold": 5000, "cards": 1, "guaranteed_legendary": 1}
        }
    }'::JSONB;

    -- Events (Vazio por enquanto)
    v_events := '[]'::JSONB;

    -- Season Pass (Configuração básica)
    v_pass := '{
        "season_id": "season_1",
        "name": "Temporada 1: O Despertar",
        "duration_days": 30,
        "tiers": 30,
        "premium_cost_runes": 500
    }'::JSONB;

    -- Feature Flags (Defaults seguros)
    v_flags := '{
        "shop_enabled": true,
        "events_enabled": false,
        "telemetry_enabled": true,
        "experimental_vfx": false,
        "chest_legendary_enabled": true
    }'::JSONB;


    -- 2. Criar Versão
    INSERT INTO public.content_versions (status, label)
    VALUES ('active', 'v1.0.0 Launch Baseline')
    RETURNING version_id INTO v_ver;

    -- 3. Inserir Blobs
    INSERT INTO public.content_blobs (version_id, blob_type, payload_json, checksum) VALUES
    (v_ver, 'card_catalog', v_cards, md5(v_cards::text)),
    (v_ver, 'balance', v_balance, md5(v_balance::text)),
    (v_ver, 'shop', v_shop, md5(v_shop::text)),
    (v_ver, 'drop_tables', v_drops, md5(v_drops::text)),
    (v_ver, 'events', v_events, md5(v_events::text)),
    (v_ver, 'season_pass', v_pass, md5(v_pass::text)),
    (v_ver, 'feature_flags', v_flags, md5(v_flags::text));

    -- 4. Ativar Versão
    INSERT INTO public.content_active (is_singleton, version_id)
    VALUES (TRUE, v_ver)
    ON CONFLICT (is_singleton) DO UPDATE SET version_id = EXCLUDED.version_id, updated_at = NOW();

    RAISE NOTICE 'Versão v1.0.0 criada e ativada com sucesso (ID: %)', v_ver;
END $$;
