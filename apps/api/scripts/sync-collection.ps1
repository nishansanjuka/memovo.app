$env:API_JSON_URL = $env:API_JSON_URL
$env:TEMP = $env:TEMP
$env:POSTMAN_API_KEY = $env:POSTMAN_API_KEY
$env:POSTMAN_COLLECTION_ID = $env:POSTMAN_COLLECTION_ID

Write-Host "Downloading OpenAPI spec..."
Invoke-WebRequest $env:API_JSON_URL -OutFile "$env:TEMP\openapi.json"

Write-Host "Converting to Postman collection..."
npx openapi-to-postmanv2 -s "$env:TEMP\openapi.json" -o "$env:TEMP\collection.json" -p -O folderStrategy=Tags

Write-Host "Patching collection..."
node ./scripts/patch-postman.mjs

Write-Host "Uploading to Postman..."
$collection = Get-Content "$env:TEMP\collection.json" -Raw
$body = @{ collection = (ConvertFrom-Json $collection) } | ConvertTo-Json -Depth 100
Invoke-RestMethod -Uri "https://api.getpostman.com/collections/$env:POSTMAN_COLLECTION_ID" -Method PUT -Headers @{ 'X-Api-Key'=$env:POSTMAN_API_KEY; 'Content-Type'='application/json' } -Body $body -ErrorAction Stop

Write-Host "Done! Collection synced to Postman!"
