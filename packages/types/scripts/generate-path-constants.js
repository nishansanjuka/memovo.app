// scripts/generate-path-constants.js
// Usage: node scripts/generate-path-constants.js <openapi_url> <output_file>

const axios = require("axios");
const fs = require("fs");
const path = require("path");

async function main() {
  const [, , openapiUrl, outputFile] = process.argv;
  if (!openapiUrl || !outputFile) {
    console.error(
      "Usage: node scripts/generate-path-constants.js <openapi_url> <output_file>",
    );
    process.exit(1);
  }
  try {
    const res = await axios.get(openapiUrl);
    const spec = res.data;
    const paths = spec.paths || {};
    const pathKeys = Object.keys(paths);
    const constants = pathKeys
      .map((p, i) => `  ${toConstName(p)}: '${p}'`)
      .join(",\n");
    const fileContent = `// Auto-generated from OpenAPI spec\nexport const API_PATHS = {\n${constants}\n};\n`;
    fs.writeFileSync(path.resolve(outputFile), fileContent);
    console.log(`Path constants written to ${outputFile}`);
  } catch (err) {
    console.error("Failed to fetch or write:", err);
    process.exit(1);
  }
}

function toConstName(pathStr) {
  // Converts '/api/v1/users/{id}' to 'api_v1_users_id'
  return pathStr
    .replace(/\{|\}|\//g, "_")
    .replace(/__+/g, "_")
    .replace(/^_+|_+$/g, "");
}

main();
