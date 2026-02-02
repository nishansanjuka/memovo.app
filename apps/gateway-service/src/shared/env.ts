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
  BASE_API_URL: z.string().url(),
  LLM_SERVICE_URL: z.string().url(),
  API_KEY: z.string(),
  NODE_ENV: z
    .enum(['development', 'production', 'test'])
    .default('development'),
  CLERK_PUBLISHABLE_KEY: z.string(),
  CLERK_SECRET_KEY: z.string(),
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
  apiUrl: string;
  llmServiceUrl: string;
  apiKey: string;
  nodeEnv: string;
}

export const baseConfig = (): BaseConfig => {
  const config = loadConfig();
  return {
    apiUrl: config.BASE_API_URL,
    llmServiceUrl: config.LLM_SERVICE_URL,
    apiKey: config.API_KEY,
    nodeEnv: config.NODE_ENV,
  };
};
