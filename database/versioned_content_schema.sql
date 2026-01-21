-- ==============================================================================
-- DUELFORGE: VERSIONED CONTENT SYSTEM (LIVE OPS)
-- ==============================================================================

-- 1. TABELAS DE VERSIONAMENTO
-- ------------------------------------------------------------------------------

-- Versões de Conteúdo (Releases)
CREATE TABLE IF NOT EXISTS public.content_versions (
    version_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    status TEXT NOT NULL CHECK (status IN ('draft', 'active', 'archived')),
    label TEXT NOT NULL, -- Ex: "v1.0.0 Launch", "v1.1.0 Balance Patch"
    created_at TIMESTAMPTZ DEFAULT NOW(),
    activated_at TIMESTAMPTZ,
    created_by UUID REFERENCES auth.users(id)
);

-- Blobs de Conteúdo (Dados JSON)
CREATE TABLE IF NOT EXISTS public.content_blobs (
    blob_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    version_id UUID REFERENCES public.content_versions(version_id) ON DELETE CASCADE,
    blob_type TEXT NOT NULL, -- 'card_catalog', 'balance', 'shop', 'drop_tables', etc.
    payload_json JSONB NOT NULL,
    checksum TEXT, -- Hash SHA256 para validação de integridade no cliente
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(version_id, blob_type)
);

-- Ponteiro para Versão Ativa (Singleton)
CREATE TABLE IF NOT EXISTS public.content_active (
    is_singleton BOOLEAN PRIMARY KEY DEFAULT TRUE CHECK (is_singleton),
    version_id UUID REFERENCES public.content_versions(version_id),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Log de Auditoria
CREATE TABLE IF NOT EXISTS public.content_audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_user_id UUID REFERENCES auth.users(id),
    action TEXT NOT NULL, -- 'create_draft', 'activate_version', 'rollback'
    details_json JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. SEGURANÇA (RLS)
-- ------------------------------------------------------------------------------

ALTER TABLE public.content_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_blobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_active ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_audit_log ENABLE ROW LEVEL SECURITY;

-- Políticas de Leitura (Público pode ler ativo indiretamente via RPC, mas bloqueamos acesso direto por padrão)
-- Admin tem acesso total (Assumindo role 'service_role' ou claim 'is_admin')
-- Para simplificar neste exemplo, vamos permitir leitura pública apenas da versão ativa se necessário,
-- mas o ideal é usar RPCs SECURITY DEFINER para controlar o acesso.

-- Bloqueia tudo por padrão para usuários anônimos/autenticados comuns
CREATE POLICY "Admin full access versions" ON public.content_versions FOR ALL USING (auth.uid() IN (SELECT id FROM auth.users WHERE raw_user_meta_data->>'is_admin' = 'true'));
CREATE POLICY "Admin full access blobs" ON public.content_blobs FOR ALL USING (auth.uid() IN (SELECT id FROM auth.users WHERE raw_user_meta_data->>'is_admin' = 'true'));
CREATE POLICY "Admin full access active" ON public.content_active FOR ALL USING (auth.uid() IN (SELECT id FROM auth.users WHERE raw_user_meta_data->>'is_admin' = 'true'));

-- 3. FUNÇÕES (RPCs)
-- ------------------------------------------------------------------------------

-- RPC: Obter Manifesto da Versão Ativa (Cliente chama isso na inicialização)
CREATE OR REPLACE FUNCTION public.get_active_content_manifest()
RETURNS TABLE (
    blob_type TEXT,
    checksum TEXT,
    updated_at TIMESTAMPTZ,
    version_label TEXT,
    version_id UUID
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cb.blob_type,
        cb.checksum,
        cb.created_at as updated_at,
        cv.label as version_label,
        cv.version_id
    FROM public.content_active ca
    JOIN public.content_versions cv ON ca.version_id = cv.version_id
    JOIN public.content_blobs cb ON cv.version_id = cb.version_id
    WHERE ca.is_singleton = TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC: Obter Blob Específico (Cliente baixa se checksum mudou)
CREATE OR REPLACE FUNCTION public.get_content_blob(p_blob_type TEXT)
RETURNS JSONB AS $$
DECLARE
    v_payload JSONB;
BEGIN
    SELECT cb.payload_json INTO v_payload
    FROM public.content_active ca
    JOIN public.content_blobs cb ON ca.version_id = cb.version_id
    WHERE ca.is_singleton = TRUE AND cb.blob_type = p_blob_type;
    
    RETURN v_payload;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC: Criar Rascunho a partir da Ativa (Admin)
CREATE OR REPLACE FUNCTION public.create_draft_from_active(p_label TEXT)
RETURNS UUID AS $$
DECLARE
    v_active_version_id UUID;
    v_new_version_id UUID;
    v_blob RECORD;
BEGIN
    -- Verifica permissão (placeholder simples, idealmente checar claims)
    IF (SELECT raw_user_meta_data->>'is_admin' FROM auth.users WHERE id = auth.uid()) IS DISTINCT FROM 'true' THEN
        RAISE EXCEPTION 'Acesso negado: Apenas admins podem criar rascunhos.';
    END IF;

    -- Pega versão ativa
    SELECT version_id INTO v_active_version_id FROM public.content_active WHERE is_singleton = TRUE;

    -- Cria nova versão Draft
    INSERT INTO public.content_versions (status, label, created_by)
    VALUES ('draft', p_label, auth.uid())
    RETURNING version_id INTO v_new_version_id;

    -- Clona blobs da ativa (se houver)
    IF v_active_version_id IS NOT NULL THEN
        FOR v_blob IN SELECT * FROM public.content_blobs WHERE version_id = v_active_version_id
        LOOP
            INSERT INTO public.content_blobs (version_id, blob_type, payload_json, checksum)
            VALUES (v_new_version_id, v_blob.blob_type, v_blob.payload_json, v_blob.checksum);
        END LOOP;
    END IF;

    -- Log Auditoria
    INSERT INTO public.content_audit_log (actor_user_id, action, details_json)
    VALUES (auth.uid(), 'create_draft', jsonb_build_object('new_version_id', v_new_version_id, 'source_version_id', v_active_version_id));

    RETURN v_new_version_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC: Ativar Versão (Admin)
CREATE OR REPLACE FUNCTION public.activate_content_version(p_version_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_old_version_id UUID;
BEGIN
    -- Verifica permissão
    IF (SELECT raw_user_meta_data->>'is_admin' FROM auth.users WHERE id = auth.uid()) IS DISTINCT FROM 'true' THEN
        RAISE EXCEPTION 'Acesso negado: Apenas admins podem ativar versões.';
    END IF;

    -- Verifica se versão existe e não está arquivada (opcional, pode reativar arquivada)
    IF NOT EXISTS (SELECT 1 FROM public.content_versions WHERE version_id = p_version_id) THEN
        RAISE EXCEPTION 'Versão não encontrada.';
    END IF;

    -- Pega versão ativa atual para arquivar
    SELECT version_id INTO v_old_version_id FROM public.content_active WHERE is_singleton = TRUE;

    -- Atualiza status da antiga para archived
    IF v_old_version_id IS NOT NULL THEN
        UPDATE public.content_versions SET status = 'archived' WHERE version_id = v_old_version_id;
    END IF;

    -- Atualiza status da nova para active e define data
    UPDATE public.content_versions SET status = 'active', activated_at = NOW() WHERE version_id = p_version_id;

    -- Atualiza ponteiro Active
    INSERT INTO public.content_active (is_singleton, version_id)
    VALUES (TRUE, p_version_id)
    ON CONFLICT (is_singleton) DO UPDATE SET version_id = EXCLUDED.version_id, updated_at = NOW();

    -- Log Auditoria
    INSERT INTO public.content_audit_log (actor_user_id, action, details_json)
    VALUES (auth.uid(), 'activate_version', jsonb_build_object('version_id', p_version_id, 'previous_version_id', v_old_version_id));

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. DADOS INICIAIS (BOOTSTRAP)
-- ------------------------------------------------------------------------------
-- Cria uma versão inicial v0.1.0 e a ativa com dados vazios/placeholders para começar

DO $$
DECLARE
    v_ver UUID;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.content_versions) THEN
        -- 1. Criar Versão
        INSERT INTO public.content_versions (status, label)
        VALUES ('active', 'v0.1.0 Initial Bootstrap')
        RETURNING version_id INTO v_ver;

        -- 2. Criar Blobs Iniciais (Placeholders baseados no schema atual)
        
        -- Card Catalog (Exemplo simplificado)
        INSERT INTO public.content_blobs (version_id, blob_type, payload_json, checksum)
        VALUES (v_ver, 'card_catalog', '[
            {"id": "thor", "rarity": "legendary", "cost": 5},
            {"id": "archer", "rarity": "common", "cost": 3}
        ]'::jsonb, 'hash_catalog_v1');

        -- Balance Rules
        INSERT INTO public.content_blobs (version_id, blob_type, payload_json, checksum)
        VALUES (v_ver, 'balance', '{
            "global_damage_mult": 1.0,
            "global_hp_mult": 1.0
        }'::jsonb, 'hash_balance_v1');

        -- Shop Config
        INSERT INTO public.content_blobs (version_id, blob_type, payload_json, checksum)
        VALUES (v_ver, 'shop', '{
            "daily_refresh_hour_utc": 0,
            "slots": 6
        }'::jsonb, 'hash_shop_v1');

        -- Drop Tables
        INSERT INTO public.content_blobs (version_id, blob_type, payload_json, checksum)
        VALUES (v_ver, 'drop_tables', '{
            "chests": ["wooden", "iron", "runic", "legendary"]
        }'::jsonb, 'hash_drops_v1');

        -- 3. Ativar
        INSERT INTO public.content_active (version_id) VALUES (v_ver);
    END IF;
END $$;
