import { baseConfig, loadConfig } from '../../shared/env';
import { API_PATHS } from '@memovo.app/types/path';

export interface WebhooksConfig {
  webhook_signing_secret: string;
}

const webhooksConfig = (): WebhooksConfig => ({
  webhook_signing_secret: loadConfig().CLERK_WEBHOOK_SIGNING_SECRET,
});

export default webhooksConfig;

export const BASE_API_URL = baseConfig().apiUrl;
export const WEBHOOKS_ROUTES = {
  UserCreated: `${BASE_API_URL}${API_PATHS.api_v1_users}`,
  UserUpdated: `${BASE_API_URL}${API_PATHS.api_v1_users_id}`,
  UserDeleted: `${BASE_API_URL}${API_PATHS.api_v1_users_id}`,
};
