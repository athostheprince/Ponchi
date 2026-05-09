export async function sendSmsCode(phone: string, code: string): Promise<void> {
  if (Deno.env.get("SMS_MODE") === "debug") {
    console.log(`Debug SMS code for ${phone}: ${code}`);
    return;
  }

  const webhookUrl = Deno.env.get("SMS_WEBHOOK_URL");

  if (!webhookUrl) {
    throw new Error("SMS_PROVIDER_NOT_CONFIGURED");
  }

  const headers: Record<string, string> = {
    "Content-Type": "application/json",
  };

  const webhookToken = Deno.env.get("SMS_WEBHOOK_TOKEN");
  if (webhookToken) {
    headers.Authorization = `Bearer ${webhookToken}`;
  }

  const response = await fetch(webhookUrl, {
    method: "POST",
    headers,
    body: JSON.stringify({ phone, code }),
  });

  if (!response.ok) {
    throw new Error(`SMS_PROVIDER_FAILED_${response.status}`);
  }
}
