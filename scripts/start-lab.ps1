$ErrorActionPreference = "Stop"

Write-Host "Starting WAF lab stack..."
docker compose up -d

Write-Host ""
Write-Host "Current containers:"
docker compose ps

Write-Host ""
Write-Host "WAF endpoint: http://127.0.0.1:8080/"
Write-Host "Health check:  http://127.0.0.1:8080/healthz"
