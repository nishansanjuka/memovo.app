$env:POSTMAN_LLM_API_JSON_URL = $env:POSTMAN_LLM_API_JSON_URL
if (-not $env:POSTMAN_LLM_API_JSON_URL) { $env:POSTMAN_LLM_API_JSON_URL = "http://localhost:7000/api-json" }
$env:TEMP = $env:TEMP
$env:POSTMAN_API_KEY = $env:POSTMAN_API_KEY
$env:POSTMAN_LLM_COLLECTION_ID = $env:POSTMAN_LLM_COLLECTION_ID

if (-not $env:POSTMAN_API_KEY -or -not $env:POSTMAN_LLM_COLLECTION_ID) {
    Write-Error "POSTMAN_API_KEY and POSTMAN_LLM_COLLECTION_ID must be set in your .env file."
    exit 1
}

Write-Host "Downloading OpenAPI spec from $env:POSTMAN_LLM_API_JSON_URL..."
Invoke-WebRequest $env:POSTMAN_LLM_API_JSON_URL -OutFile "$env:TEMP\openapi_llm.json"

Write-Host "Converting to Postman collection..."
npx openapi-to-postmanv2 -s "$env:TEMP\openapi_llm.json" -o "$env:TEMP\collection_llm.json" -p -O folderStrategy=Tags

Write-Host "Patching collection..."
node ./scripts/patch-postman.mjs

Write-Host "Uploading to Postman..."
$collection = Get-Content "$env:TEMP\collection_llm.json" -Raw
$body = @{ collection = (ConvertFrom-Json $collection) } | ConvertTo-Json -Depth 100
Invoke-RestMethod -Uri "https://api.getpostman.com/collections/$env:POSTMAN_LLM_COLLECTION_ID" -Method PUT -Headers @{ 'X-Api-Key'=$env:POSTMAN_API_KEY; 'Content-Type'='application/json' } -Body $body -ErrorAction Stop

Write-Host "Done! LLM Service collection synced to Postman!"
