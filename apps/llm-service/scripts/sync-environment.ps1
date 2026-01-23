$env:TEMP = $env:TEMP
$env:POSTMAN_API_KEY = $env:POSTMAN_API_KEY
$env:POSTMAN_LLM_ENVIRONMENT_ID = $env:POSTMAN_LLM_ENVIRONMENT_ID

if (-not $env:POSTMAN_API_KEY -or -not $env:POSTMAN_LLM_ENVIRONMENT_ID) {
    Write-Error "POSTMAN_API_KEY and POSTMAN_LLM_ENVIRONMENT_ID must be set in your .env file."
    exit 1
}

Write-Host "Creating environment with keys..."
node ./scripts/sync-postman-env.mjs

Write-Host "Syncing environment to Postman..."
$env_data = Get-Content "$env:TEMP\postman-llm-environment.json" -Raw
$body = @{ environment = (ConvertFrom-Json $env_data) } | ConvertTo-Json -Depth 100

try {
    # Update the environment
    Invoke-RestMethod -Uri "https://api.getpostman.com/environments/$env:POSTMAN_LLM_ENVIRONMENT_ID" -Method PUT -Headers @{ 'X-Api-Key' = $env:POSTMAN_API_KEY; 'Content-Type' = 'application/json' } -Body $body -ErrorAction Stop | Out-Null
    Write-Host "Environment updated successfully!"
}
catch {
    Write-Error "Failed to update Postman environment: $($_.Exception.Message)"
    exit 1
}

Write-Host "Done! LLM Service environment synced to Postman!"
