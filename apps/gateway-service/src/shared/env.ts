import z from 'zod';

// Ensure .env is loaded for Node versions that support it (v20.12.0+)
if (
  process.env.NODE_ENV !== 'production' &&
  typeof process.loadEnvFile === 'function'
) {
  try {
    process.loadEnvFile();
  } catch {
    // .env file might not exist, ignore
  }
}

export const configSchema = z.object({
  CLERK_WEBHOOK_SIGNING_SECRET: z.string(),
  BASE_API_URL: z.url(),
  API_KEY: z.string(),
});

export type EnvConfig = z.infer<typeof configSchema>;

export const loadConfig = (): EnvConfig => {
  const parsed = configSchema.safeParse(process.env);
  if (!parsed.success) {
    console.error(parsed.error.format());
    throw new Error('❌ Invalid environment variables');
  }
  return parsed.data;
};

export interface BaseConfig {
  url: string;
  apiKey: string;
}

export const baseConfig = (): BaseConfig => ({
  url: loadConfig().BASE_API_URL,
  apiKey: loadConfig().API_KEY,
});
