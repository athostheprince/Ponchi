export const PHONE_RE = /^\+7\d{10}$/;
export const CODE_RE = /^\d{4}$/;
export const MIN_PASSWORD_LENGTH = 6;
export const SESSION_TTL_MS = 30 * 24 * 60 * 60 * 1000;
export const MAX_CODE_ATTEMPTS = 5;

export function createAccessToken(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(32));
  return Array.from(bytes, (byte) => byte.toString(16).padStart(2, "0")).join("");
}

export function sessionExpiresAt(): string {
  return new Date(Date.now() + SESSION_TTL_MS).toISOString();
}
