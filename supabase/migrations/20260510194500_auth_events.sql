-- Ponchi auth event journal.
-- This table is for backend observability while auth is handled by Edge Functions.

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

CREATE TABLE IF NOT EXISTS public.auth_events (
  id UUID PRIMARY KEY DEFAULT extensions.gen_random_uuid(),
  event_type TEXT NOT NULL,
  phone TEXT,
  user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  success BOOLEAN NOT NULL DEFAULT TRUE,
  error_code TEXT,
  metadata JSONB NOT NULL DEFAULT '{}'::JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_auth_events_created_at
ON public.auth_events(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_auth_events_phone_created_at
ON public.auth_events(phone, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_auth_events_user_id_created_at
ON public.auth_events(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_auth_events_event_type_created_at
ON public.auth_events(event_type, created_at DESC);

ALTER TABLE public.auth_events ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE VIEW public.auth_activity
WITH (security_invoker = true) AS
SELECT
  e.created_at AS event_time,
  e.event_type,
  e.success,
  e.error_code,
  e.phone,
  e.user_id::TEXT AS user_id,
  u.name,
  NULL::TEXT AS active_code,
  NULL::TEXT AS code_purpose,
  NULL::INTEGER AS code_attempts,
  NULL::TIMESTAMPTZ AS code_expires_at,
  e.metadata
FROM public.auth_events e
LEFT JOIN public.users u ON u.id = e.user_id

UNION ALL

SELECT
  s.created_at AS event_time,
  'active_sms_code' AS event_type,
  TRUE AS success,
  NULL::TEXT AS error_code,
  s.phone,
  NULL::TEXT AS user_id,
  NULL::TEXT AS name,
  s.code AS active_code,
  s.purpose AS code_purpose,
  s.attempts AS code_attempts,
  s.expires_at AS code_expires_at,
  jsonb_build_object('expires_in_seconds', GREATEST(0, FLOOR(EXTRACT(EPOCH FROM (s.expires_at - NOW()))))::INT) AS metadata
FROM public.sms_codes s;
