// scripts/patch-postman.mjs
import fs from 'fs';
import path from 'path';

const tempPath = process.env.TEMP || process.env.TMP;
const collectionPath = path.join(tempPath, 'collection_llm.json');

console.log('🔧 Reading collection:', collectionPath);

if (!fs.existsSync(collectionPath)) {
  console.error('❌ Collection not found at', collectionPath);
  process.exit(1);
}

const collection = JSON.parse(fs.readFileSync(collectionPath, 'utf-8'));

// --- Replace baseUrl with llmServiceBaseUrl in the entire collection ---
let collectionStr = JSON.stringify(collection, null, 2);
collectionStr = collectionStr.replace(/\{\{baseUrl\}\}/g, '{{llmServiceBaseUrl}}');
const updatedCollection = JSON.parse(collectionStr);

fs.writeFileSync(collectionPath, JSON.stringify(updatedCollection, null, 2));
console.log('✅ Postman collection patched with llmServiceBaseUrl!');
