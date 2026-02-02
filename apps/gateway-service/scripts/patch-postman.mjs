// scripts/patch-postman.mjs
import fs from 'fs';
import path from 'path';

const tempPath = process.env.TEMP || process.env.TMP;
const collectionPath = path.join(tempPath, 'gateway-collection.json');
const preRequestScriptPath = path.resolve('./scripts/pre-request.js');

console.log('🔧 Reading Gateway collection:', collectionPath);

if (!fs.existsSync(collectionPath)) {
  console.error('❌ Collection not found at', collectionPath);
  process.exit(1);
}

if (!fs.existsSync(preRequestScriptPath)) {
  console.error('❌ Pre-request script not found at', preRequestScriptPath);
  process.exit(1);
}

const collectionWrapper = JSON.parse(fs.readFileSync(collectionPath, 'utf-8'));
const preScript = fs.readFileSync(preRequestScriptPath, 'utf-8');

// openapi-to-postmanv2 outputs either { collection: {...} } or just {...}
const collection = collectionWrapper.collection || collectionWrapper;

// Pre-request script event object
const preRequestEvent = {
  listen: 'prerequest',
  script: {
    type: 'text/javascript',
    exec: preScript.split('\n'),
  },
};

// --- Inject pre-request script at collection level ---
collection.event = collection.event || [];
collection.event = collection.event.filter((e) => e.listen !== 'prerequest');
collection.event.push(preRequestEvent);

// --- Also inject into each folder AND request to ensure it runs ---
function addScriptToItems(items) {
  if (!items || !Array.isArray(items)) return;

  for (const item of items) {
    item.event = item.event || [];
    item.event = item.event.filter((e) => e.listen !== 'prerequest');
    item.event.push(preRequestEvent);

    // If it's a folder (has nested items), recurse
    if (item.item && Array.isArray(item.item)) {
      addScriptToItems(item.item);
    }
  }
}

addScriptToItems(collection.item);

console.log(
  '📝 Added pre-request script with',
  preScript.split('\n').length,
  'lines to collection and all folders',
);

// --- Replace baseUrl with gatewayBaseUrl in the entire collection ---
let collectionStr = JSON.stringify(collection, null, 2);
collectionStr = collectionStr.replace(/\{\{baseUrl\}\}/g, '{{gatewayBaseUrl}}');
const updatedCollection = JSON.parse(collectionStr);

// Write back in the same format
const output = collectionWrapper.collection
  ? { collection: updatedCollection }
  : updatedCollection;
fs.writeFileSync(collectionPath, JSON.stringify(output, null, 2));
console.log(
  '✅ Gateway Postman collection patched with pre-request script and gatewayBaseUrl!',
);
