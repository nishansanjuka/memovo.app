// scripts/patch-postman.mjs
import fs from "fs";
import path from "path";

const tempPath = process.env.TEMP || process.env.TMP;
const collectionPath = path.join(tempPath, "collection.json");
const preRequestScriptPath = path.resolve("./scripts/pre-request.js");

console.log("🔧 Reading collection:", collectionPath);

if (!fs.existsSync(collectionPath)) {
  console.error("❌ Collection not found at", collectionPath);
  process.exit(1);
}

if (!fs.existsSync(preRequestScriptPath)) {
  console.error("❌ Pre-request script not found at", preRequestScriptPath);
  process.exit(1);
}

const collectionWrapper = JSON.parse(fs.readFileSync(collectionPath, "utf-8"));
const preScript = fs.readFileSync(preRequestScriptPath, "utf-8");

// openapi-to-postmanv2 outputs either { collection: {...} } or just {...}
const collection = collectionWrapper.collection || collectionWrapper;

// --- Inject pre-request script globally ---
collection.event = collection.event || [];

// Remove any existing pre-request events to avoid duplication
collection.event = collection.event.filter((e) => e.listen !== "prerequest");

// Add our script
collection.event.push({
  listen: "prerequest",
  script: {
    type: "text/javascript",
    exec: preScript.split("\n"),
  },
});

console.log(
  "📝 Added pre-request script with",
  preScript.split("\n").length,
  "lines",
);

// --- Replace baseUrl with apiBaseUrl in the entire collection ---
let collectionStr = JSON.stringify(collection, null, 2);
collectionStr = collectionStr.replace(/\{\{baseUrl\}\}/g, "{{apiBaseUrl}}");
const updatedCollection = JSON.parse(collectionStr);

// Write back in the same format
const output = collectionWrapper.collection
  ? { collection: updatedCollection }
  : updatedCollection;
fs.writeFileSync(collectionPath, JSON.stringify(output, null, 2));
console.log(
  "✅ Postman collection patched with pre-request script and apiBaseUrl!",
);
