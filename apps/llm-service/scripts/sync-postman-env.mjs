import fs from "fs";
import path from "path";

console.log("🔧 Creating Postman environment for LLM Service...");

// Read environment variables
const apiBaseUrl = process.env.BASE_URL || "http://localhost:8080";
const llmServiceBaseUrl =
  process.env.LLM_SERVICE_BASE_URL || "http://localhost:7000";
const gatewayBaseUrl = process.env.GATEWAY_BASE_URL || "http://localhost:4000";
const clerkSecretKey = process.env.CLERK_SECRET_KEY || "";
const testUserId = process.env.TEST_CLERK_USER_ID || "";

// Create environment with actual values
const environment = {
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
  _postman_exported_using: "Memovo LLM Service Sync Script",
};

const tempPath = process.env.TEMP || process.env.TMP;
const outputPath = path.join(tempPath, "postman-llm-environment.json");

fs.writeFileSync(outputPath, JSON.stringify(environment, null, 2));
console.log("✅ Environment created at:", outputPath);
console.log("📋 Values:", { apiBaseUrl, llmServiceBaseUrl, gatewayBaseUrl });
