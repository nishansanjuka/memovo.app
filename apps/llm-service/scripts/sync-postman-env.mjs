import fs from 'fs';
import path from 'path';

console.log('🔧 Creating Postman environment for LLM Service...');

// Read environment variables
const baseUrl = process.env.LLM_SERVICE_BASE_URL || 'http://localhost:7000';

// Create environment with actual values
const environment = {
  name: 'Memovo LLM Service',
  values: [
    { key: 'baseUrl', value: baseUrl, enabled: true },
  ],
  _postman_variable_scope: 'environment',
  _postman_exported_at: new Date().toISOString(),
  _postman_exported_using: 'Memovo LLM Service Sync Script',
};

const tempPath = process.env.TEMP || process.env.TMP;
const outputPath = path.join(tempPath, 'postman-llm-environment.json');

fs.writeFileSync(outputPath, JSON.stringify(environment, null, 2));
console.log('✅ Environment created at:', outputPath);
console.log('📋 Values:', { baseUrl });
