import z from 'zod';
import webhooksConfig, {
  WebhooksConfig,
} from '../modules/webhooks/webhooks.config';
export interface Configuration {
  webhooks: WebhooksConfig;
}

export const configuration = (): Configuration => ({
  webhooks: webhooksConfig(),
});

export const configSchema = z.object({
  CLERK_WEBHOOK_SIGNING_SECRET: z.string(),
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
