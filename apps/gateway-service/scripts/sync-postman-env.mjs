// scripts/sync-postman-env.mjs
import fs from 'fs';
import path from 'path';

const envTemplatePath = path.resolve('./scripts/postman-env-dev.json');

console.log('🔧 Creating Gateway Postman environment with actual keys...');

if (!fs.existsSync(envTemplatePath)) {
  console.error('❌ Environment template not found at', envTemplatePath);
  process.exit(1);
}

// Read environment variables from process.env (loaded by dotenv-cli)
const clerkSecretKey = process.env.CLERK_SECRET_KEY;
const testUserId = process.env.TEST_CLERK_USER_ID;
const gatewayBaseUrl = process.env.GATEWAY_BASE_URL || 'http://localhost:4000';
const apiBaseUrl = process.env.BASE_API_URL || 'http://localhost:8080';
const llmServiceBaseUrl =
  process.env.LLM_SERVICE_URL || 'http://localhost:8000';
const apiKey = process.env.API_KEY || '';

if (!clerkSecretKey) {
  console.error('❌ CLERK_SECRET_KEY not found in environment');
  process.exit(1);
}

if (!testUserId) {
  console.error('❌ TEST_CLERK_USER_ID not found in environment');
  process.exit(1);
}

// Create environment with ALL values needed across all collections
const environment = {
  id: 'memovo-gateway-dev-env',
  name: 'Memovo Gateway ENV',
  values: [
    { key: 'gatewayBaseUrl', value: gatewayBaseUrl, enabled: true },
    { key: 'apiBaseUrl', value: apiBaseUrl, enabled: true },
    { key: 'llmServiceBaseUrl', value: llmServiceBaseUrl, enabled: true },
    { key: 'CLERK_SECRET_KEY', value: clerkSecretKey, enabled: true },
    { key: 'TEST_CLERK_USER_ID', value: testUserId, enabled: true },
    { key: 'API_KEY', value: apiKey, enabled: true },
    { key: 'bearerToken', value: '', enabled: true },
  ],
  _postman_variable_scope: 'environment',
  _postman_exported_at: new Date().toISOString(),
  _postman_exported_using: 'Memovo Gateway Sync Script',
};

const tempPath = process.env.TEMP || process.env.TMP;
const outputPath = path.join(tempPath, 'gateway-postman-environment.json');

fs.writeFileSync(outputPath, JSON.stringify(environment, null, 2));
console.log('✅ Gateway environment created at:', outputPath);
console.log('📋 Values:', {
  gatewayBaseUrl,
  apiBaseUrl,
  llmServiceBaseUrl,
  CLERK_SECRET_KEY: clerkSecretKey.substring(0, 15) + '...',
  TEST_CLERK_USER_ID: testUserId,
  API_KEY: apiKey ? apiKey.substring(0, 10) + '...' : '(not set)',
});
