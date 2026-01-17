import { loadConfig } from '../../shared/config';

export interface WebhooksConfig {
  webhook_signing_secret: string;
}

const webhooksConfig = (): WebhooksConfig => ({
  webhook_signing_secret: loadConfig().CLERK_WEBHOOK_SIGNING_SECRET,
});

export default webhooksConfig;
