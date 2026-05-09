-- Ponchi auth week 2 migration
-- Run this once in DBeaver before deploying the updated auth functions.

ALTER TABLE sms_codes
ADD COLUMN IF NOT EXISTS attempts INTEGER NOT NULL DEFAULT 0;

CREATE INDEX IF NOT EXISTS idx_sms_codes_phone_purpose_created_at
ON sms_codes (phone, purpose, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_sessions_token
ON sessions (token);

CREATE INDEX IF NOT EXISTS idx_sessions_user_id
ON sessions (user_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_users_phone_unique
ON users (phone);
