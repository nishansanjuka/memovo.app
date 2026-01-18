// Utility to forward a request using fetch with method and body only
// Usage: forwardReq(url, method, body)

import { logDebug } from "./logdebug.js";

export async function forwardReq(
  url: string,
  method: string,
  body?: any,
): Promise<Response> {
  logDebug(
    `Forwarding request to ${url} with method ${method} and body: ${JSON.stringify(body)}`,
  );
  return fetch(url, {
    method,
    headers: {
      "Content-Type": "application/json",
    },
    body: body ? JSON.stringify(body) : undefined,
  });
}
