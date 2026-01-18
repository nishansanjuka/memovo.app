// scripts/generate-schemas.js
// Usage: node scripts/generate-schemas.js <openapi_url> <output_file>

const axios = require("axios");
const fs = require("fs");
const path = require("path");

function jsType(openapiType, format) {
  if (openapiType === "integer" || openapiType === "number") return "number";
  if (openapiType === "boolean") return "boolean";
  if (openapiType === "array") return "any[]";
  if (openapiType === "object") return "Record<string, any>";
  if (openapiType === "string" && format === "date-time") return "string";
  return "string";
}

function schemaToInterface(name, schema) {
  if (!schema.properties) return `export interface ${name} {}`;
  const props = Object.entries(schema.properties)
    .map(([key, prop]) => {
      const optional =
        schema.required && !schema.required.includes(key) ? "?" : "";
      const type = jsType(prop.type, prop.format);
      const desc = prop.description ? `  /** ${prop.description} */\n` : "";
      return `${desc}  ${key}${optional}: ${type};`;
    })
    .join("\n");
  return `export interface ${name} {\n${props}\n}`;
}

async function main() {
  const [, , openapiUrl, outputFile] = process.argv;
  if (!openapiUrl || !outputFile) {
    console.error(
      "Usage: node scripts/generate-schemas.js <openapi_url> <output_file>",
    );
    process.exit(1);
  }
  try {
    const res = await axios.get(openapiUrl);
    const spec = res.data;
    const schemas =
      spec.components && spec.components.schemas ? spec.components.schemas : {};
    const interfaces = Object.entries(schemas)
      .map(([name, schema]) => schemaToInterface(name, schema))
      .join("\n\n");
    const fileContent = `// Auto-generated from OpenAPI spec\n${interfaces}\n`;
    fs.writeFileSync(path.resolve(outputFile), fileContent);
    console.log(`Schemas written to ${outputFile}`);
  } catch (err) {
    console.error("Failed to fetch or write:", err);
    process.exit(1);
  }
}

main();
