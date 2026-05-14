import { sql } from "./db.ts";

type AuthEvent = {
  eventType: string;
  phone?: string | null;
  userId?: string | null;
  success?: boolean;
  errorCode?: string | null;
  metadata?: Record<string, unknown>;
};

export async function logAuthEvent(event: AuthEvent, db = sql): Promise<void> {
  try {
    await db`
      INSERT INTO auth_events (
        event_type,
        phone,
        user_id,
        success,
        error_code,
        metadata
      )
      VALUES (
        ${event.eventType},
        ${event.phone ?? null},
        ${event.userId ?? null},
        ${event.success ?? true},
        ${event.errorCode ?? null},
        ${JSON.stringify(event.metadata ?? {})}::jsonb
      )
    `;
  } catch (error) {
    console.error("auth event logging failed", error);
  }
}
