export function logDebug(message: unknown, ...optionalParams: unknown[]) {
  if (process.env.NODE_ENV !== 'production') {
    console.log('[DEBUG]', message, ...optionalParams);
  }
}
