import webhooksConfig, {
  WebhooksConfig,
} from '../modules/webhooks/webhooks.config';
import { baseConfig, BaseConfig } from './env';

export interface Configuration {
  webhooks: WebhooksConfig;
  base: BaseConfig;
}

export const configuration = (): Configuration => ({
  webhooks: webhooksConfig(),
  base: baseConfig(),
});

export * from './env';
export * from './config/service-registry';
