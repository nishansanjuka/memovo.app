$env:GATEWAY_API_JSON_URL = $env:GATEWAY_API_JSON_URL
$env:TEMP = $env:TEMP
$env:POSTMAN_API_KEY = $env:POSTMAN_API_KEY
$env:GATEWAY_POSTMAN_COLLECTION_ID = $env:GATEWAY_POSTMAN_COLLECTION_ID

Write-Host "Downloading Gateway OpenAPI spec..."
Invoke-WebRequest $env:GATEWAY_API_JSON_URL -OutFile "$env:TEMP\gateway-openapi.json"

Write-Host "Converting to Postman collection..."
npx openapi-to-postmanv2 -s "$env:TEMP\gateway-openapi.json" -o "$env:TEMP\gateway-collection.json" -p -O folderStrategy=Tags

Write-Host "Patching collection..."
node ./scripts/patch-postman.mjs

Write-Host "Uploading to Postman..."
$collection = Get-Content "$env:TEMP\gateway-collection.json" -Raw
$body = @{ collection = (ConvertFrom-Json $collection) } | ConvertTo-Json -Depth 100
Invoke-RestMethod -Uri "https://api.getpostman.com/collections/$env:GATEWAY_POSTMAN_COLLECTION_ID" -Method PUT -Headers @{ 'X-Api-Key'=$env:POSTMAN_API_KEY; 'Content-Type'='application/json' } -Body $body -ErrorAction Stop

Write-Host "Done! Gateway collection synced to Postman!"
