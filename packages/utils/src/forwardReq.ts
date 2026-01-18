// Utility to forward a request using fetch with method and body only
// Usage: forwardReq(url, method, body)

export async function forwardReq(
  url: string,
  method: string,
  body?: any,
): Promise<Response> {
  return fetch(url, {
    method,
    headers: {
      "Content-Type": "application/json",
    },
    body: body ? JSON.stringify(body) : undefined,
  });
}
