-- ==============================================================================
-- DUELFORGE: RBAC & ADMIN CONSOLE SECURITY
-- ==============================================================================

-- 1. TABELAS DE CONTROLE DE ACESSO
-- ------------------------------------------------------------------------------

-- Tabela de Roles (Papéis)
CREATE TABLE IF NOT EXISTS public.user_roles (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('player', 'support', 'analyst', 'admin')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Log de Ações Administrativas (Audit Trail)
CREATE TABLE IF NOT EXISTS public.admin_actions_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_user_id UUID REFERENCES auth.users(id),
    action TEXT NOT NULL, -- Ex: 'ban_user', 'grant_compensation', 'activate_version'
    target_user_id UUID REFERENCES auth.users(id), -- Opcional, se a ação for sobre um usuário
    details_json JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Habilitar RLS
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_actions_log ENABLE ROW LEVEL SECURITY;

-- 2. FUNÇÕES AUXILIARES (HELPERS)
-- ------------------------------------------------------------------------------

-- Verifica se o usuário atual tem role de Admin
CREATE OR REPLACE FUNCTION public.is_admin() RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_roles 
        WHERE user_id = auth.uid() AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Verifica se o usuário atual tem role de Suporte ou superior
CREATE OR REPLACE FUNCTION public.is_support() RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_roles 
        WHERE user_id = auth.uid() AND role IN ('admin', 'support')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Verifica se o usuário atual tem role de Analista ou superior
CREATE OR REPLACE FUNCTION public.is_analyst() RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_roles 
        WHERE user_id = auth.uid() AND role IN ('admin', 'analyst')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. POLÍTICAS DE SEGURANÇA (RLS)
-- ------------------------------------------------------------------------------

-- User Roles:
-- Admin pode ver e editar tudo.
-- Usuário comum NÃO pode ver sua role diretamente por aqui (usa auth metadata ou função específica se precisar).
CREATE POLICY "Admin manage roles" ON public.user_roles
    FOR ALL USING (public.is_admin());

-- Admin Actions Log:
-- Admin e Analista podem ver logs.
-- Ninguém pode apagar ou editar logs (Append Only).
CREATE POLICY "Admin/Analyst view logs" ON public.admin_actions_log
    FOR SELECT USING (public.is_analyst());

-- 4. PERMISSÕES ESPECÍFICAS POR ROLE
-- ------------------------------------------------------------------------------

-- SUPORTE:
-- Pode ver dados de qualquer jogador para ajudar em tickets.
-- NÃO pode editar diretamente, deve usar RPCs auditadas.

-- Política para Suporte ler Players (sobrescreve ou complementa a política "Users view own profile")
CREATE POLICY "Support view all players" ON public.players
    FOR SELECT USING (public.is_support());

-- Política para Suporte ler User Cards
CREATE POLICY "Support view all cards" ON public.user_cards
    FOR SELECT USING (public.is_support());

-- Política para Suporte ler Ledger (Histórico de recompensas)
CREATE POLICY "Support view all ledgers" ON public.reward_ledger
    FOR SELECT USING (public.is_support());

-- ANALISTA:
-- Pode ver métricas e dados agregados (via views ou tabelas diretas).
-- Acesso de leitura similar ao suporte, mas focado em dados globais.
-- (Neste exemplo, usa as mesmas permissões de leitura do suporte para tabelas de usuário)

-- ADMIN:
-- Acesso total já garantido pelas funções de verificação nas RPCs críticas.
-- Para tabelas de conteúdo (Content Versions), já definimos políticas baseadas em metadados, 
-- mas podemos migrar para usar a tabela `user_roles` para consistência.

-- Atualizando políticas de Content Versions para usar a tabela user_roles
DROP POLICY IF EXISTS "Admin full access versions" ON public.content_versions;
CREATE POLICY "Admin full access versions" ON public.content_versions
    FOR ALL USING (public.is_admin());

DROP POLICY IF EXISTS "Admin full access blobs" ON public.content_blobs;
CREATE POLICY "Admin full access blobs" ON public.content_blobs
    FOR ALL USING (public.is_admin());

DROP POLICY IF EXISTS "Admin full access active" ON public.content_active;
CREATE POLICY "Admin full access active" ON public.content_active
    FOR ALL USING (public.is_admin());

-- 5. RPCs ADMINISTRATIVAS AUDITADAS
-- ------------------------------------------------------------------------------

-- RPC: Grant Compensation (Suporte/Admin)
-- Permite dar recursos limitados como compensação.
CREATE OR REPLACE FUNCTION public.grant_compensation(
    p_target_user_id UUID,
    p_reason TEXT,
    p_gold INT DEFAULT 0,
    p_runes INT DEFAULT 0
) RETURNS UUID AS $$
DECLARE
    v_rewards JSONB := '[]'::JSONB;
    v_ledger_id UUID;
BEGIN
    -- Verificação de Permissão
    IF NOT public.is_support() THEN
        RAISE EXCEPTION 'Acesso negado.';
    END IF;

    -- Limites de segurança para Suporte (Admin pode ignorar se quiser, mas aqui aplicamos geral)
    IF p_gold > 5000 OR p_runes > 100 THEN
        IF NOT public.is_admin() THEN
            RAISE EXCEPTION 'Valor excede limite para suporte. Peça a um admin.';
        END IF;
    END IF;

    -- Monta payload
    IF p_gold > 0 THEN
        v_rewards := v_rewards || jsonb_build_object('type', 'currency', 'id', 'gold', 'amount', p_gold);
    END IF;
    IF p_runes > 0 THEN
        v_rewards := v_rewards || jsonb_build_object('type', 'currency', 'id', 'runes', 'amount', p_runes);
    END IF;

    -- Executa grant interno
    v_ledger_id := public._internal_grant_rewards(p_target_user_id, v_rewards, 'compensation', p_reason);

    -- Log de Auditoria
    INSERT INTO public.admin_actions_log (actor_user_id, action, target_user_id, details_json)
    VALUES (auth.uid(), 'grant_compensation', p_target_user_id, jsonb_build_object(
        'reason', p_reason,
        'gold', p_gold,
        'runes', p_runes,
        'ledger_id', v_ledger_id
    ));

    RETURN v_ledger_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. BOOTSTRAP (Opcional: Auto-promover o primeiro usuário a Admin para não travar)
-- ------------------------------------------------------------------------------
-- (Isso deve ser rodado manualmente ou controlado, deixamos comentado por segurança)
/*
INSERT INTO public.user_roles (user_id, role)
SELECT id, 'admin' FROM auth.users ORDER BY created_at ASC LIMIT 1
ON CONFLICT DO NOTHING;
*/
