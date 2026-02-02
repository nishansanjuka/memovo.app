// scripts/sync-postman-env.mjs
import fs from "fs";
import path from "path";

const envTemplatePath = path.resolve("./scripts/postman-env-dev.json");

console.log("🔧 Creating Postman environment with actual keys...");

if (!fs.existsSync(envTemplatePath)) {
  console.error("❌ Environment template not found at", envTemplatePath);
  process.exit(1);
}

// Read environment variables from process.env (loaded by dotenv-cli)
const clerkSecretKey = process.env.CLERK_SECRET_KEY;
const testUserId = process.env.TEST_CLERK_USER_ID;
const apiBaseUrl = process.env.BASE_URL || "http://localhost:8080";
const llmServiceBaseUrl =
  process.env.LLM_SERVICE_BASE_URL || "http://localhost:7000";
const gatewayBaseUrl = process.env.GATEWAY_BASE_URL || "http://localhost:4000";

if (!clerkSecretKey) {
  console.error("❌ CLERK_SECRET_KEY not found in environment");
  process.exit(1);
}

if (!testUserId) {
  console.error("❌ TEST_CLERK_USER_ID not found in environment");
  process.exit(1);
}

// Create environment with actual values
const environment = {
  id: "memovo-dev-env",
  name: "Memovo ENV",
  values: [
    { key: "apiBaseUrl", value: apiBaseUrl, enabled: true },
    { key: "llmServiceBaseUrl", value: llmServiceBaseUrl, enabled: true },
    { key: "gatewayBaseUrl", value: gatewayBaseUrl, enabled: true },
    { key: "CLERK_SECRET_KEY", value: clerkSecretKey, enabled: true },
    { key: "TEST_CLERK_USER_ID", value: testUserId, enabled: true },
    { key: "bearerToken", value: "", enabled: true },
  ],
  _postman_variable_scope: "environment",
  _postman_exported_at: new Date().toISOString(),
  _postman_exported_using: "Memovo API Sync Script",
};

const tempPath = process.env.TEMP || process.env.TMP;
const outputPath = path.join(tempPath, "postman-environment.json");

fs.writeFileSync(outputPath, JSON.stringify(environment, null, 2));
console.log("✅ Environment created at:", outputPath);
console.log("📋 Values:", {
  apiBaseUrl,
  llmServiceBaseUrl,
  gatewayBaseUrl,
  CLERK_SECRET_KEY: clerkSecretKey.substring(0, 15) + "...",
  TEST_CLERK_USER_ID: testUserId,
});
