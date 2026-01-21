-- ==============================================================================
-- DUELFORGE: TELEMETRY SCHEMA
-- ==============================================================================

-- Tabela de Eventos de Telemetria
-- Projetada para alto volume de inserção (Append Only)
CREATE TABLE IF NOT EXISTS public.telemetry_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL, -- 'match_start', 'match_end', 'card_played', etc.
    payload_json JSONB NOT NULL, -- Dados específicos do evento
    client_timestamp TIMESTAMPTZ NOT NULL, -- Hora que ocorreu no cliente
    server_timestamp TIMESTAMPTZ DEFAULT NOW() -- Hora que chegou no servidor
);

-- Índices para Análise
CREATE INDEX IF NOT EXISTS idx_telemetry_type_time ON public.telemetry_events(event_type, server_timestamp);
CREATE INDEX IF NOT EXISTS idx_telemetry_user ON public.telemetry_events(user_id);

-- RLS
ALTER TABLE public.telemetry_events ENABLE ROW LEVEL SECURITY;

-- Jogadores podem apenas INSERIR seus próprios eventos
CREATE POLICY "Users insert own telemetry" ON public.telemetry_events
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Jogadores NÃO podem ler telemetria (apenas seus próprios dados se muito necessário, mas evitamos para economizar)
-- Bloqueamos SELECT por padrão para players.

-- Analistas e Admins podem ler tudo
CREATE POLICY "Analysts view all telemetry" ON public.telemetry_events
    FOR SELECT USING (public.is_analyst());

-- RPC: Ingestão em Lote (Otimizada)
-- Recebe array de eventos para reduzir round-trips
CREATE OR REPLACE FUNCTION public.ingest_telemetry_batch(events JSONB)
RETURNS VOID AS $$
DECLARE
    e JSONB;
BEGIN
    FOR e IN SELECT * FROM jsonb_array_elements(events)
    LOOP
        INSERT INTO public.telemetry_events (user_id, event_type, payload_json, client_timestamp)
        VALUES (
            auth.uid(),
            e->>'event_type',
            e->'payload',
            (e->>'timestamp')::TIMESTAMPTZ
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
