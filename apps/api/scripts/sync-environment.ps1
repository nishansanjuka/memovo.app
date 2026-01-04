$env:TEMP = $env:TEMP
$env:POSTMAN_API_KEY = $env:POSTMAN_API_KEY
$env:POSTMAN_ENVIRONMENT_ID = $env:POSTMAN_ENVIRONMENT_ID

Write-Host "Creating environment with keys..."
node ./scripts/sync-postman-env.mjs

Write-Host "Checking if environment exists in Postman..."
$env_data = Get-Content "$env:TEMP\postman-environment.json" -Raw
$body = @{ environment = (ConvertFrom-Json $env_data) } | ConvertTo-Json -Depth 100

try {
    # Try to get the environment to check if it exists
    Invoke-RestMethod -Uri "https://api.getpostman.com/environments/$env:POSTMAN_ENVIRONMENT_ID" -Method GET -Headers @{ 'X-Api-Key' = $env:POSTMAN_API_KEY } -ErrorAction Stop | Out-Null
    
    Write-Host "Environment exists, updating..."
    Invoke-RestMethod -Uri "https://api.getpostman.com/environments/$env:POSTMAN_ENVIRONMENT_ID" -Method PUT -Headers @{ 'X-Api-Key' = $env:POSTMAN_API_KEY; 'Content-Type' = 'application/json' } -Body $body -ErrorAction Stop | Out-Null
    Write-Host "Environment updated successfully!"
}
catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Host "Environment not found, creating new..."
        Invoke-RestMethod -Uri "https://api.getpostman.com/environments" -Method POST -Headers @{ 'X-Api-Key' = $env:POSTMAN_API_KEY; 'Content-Type' = 'application/json' } -Body $body -ErrorAction Stop | Out-Null
        Write-Host "Environment created successfully!"
    }
    else {
        throw $_
    }
}

Write-Host "Done! Environment synced to Postman!"
