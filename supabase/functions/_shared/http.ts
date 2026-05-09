export const jsonHeaders = {
  "Content-Type": "application/json",
};

export function json(status: number, payload: unknown): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: jsonHeaders,
  });
}

export async function readJson(req: Request): Promise<Record<string, unknown> | null> {
  try {
    const body = await req.json();
    return body && typeof body === "object" && !Array.isArray(body)
      ? body as Record<string, unknown>
      : null;
  } catch {
    return null;
  }
}

export function requireMethod(req: Request, method: string): Response | null {
  if (req.method === method) {
    return null;
  }

  return json(405, { error: "METHOD_NOT_ALLOWED" });
}

export function getBearerToken(req: Request): string | null {
  const authorization = req.headers.get("authorization");

  if (!authorization) {
    return null;
  }

  const [scheme, token] = authorization.trim().split(/\s+/, 2);

  return scheme === "Bearer" && token ? token : null;
}
