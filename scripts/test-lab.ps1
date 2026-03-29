$ErrorActionPreference = "Stop"

Write-Host "Testing normal traffic..."
curl.exe -i http://127.0.0.1:8088/

Write-Host ""
Write-Host "Testing XSS-like payload..."
curl.exe -i "http://127.0.0.1:8088/?test=%3Cscript%3Ealert(1)%3C%2Fscript%3E"

Write-Host ""
Write-Host "Testing SQLi-like payload..."
curl.exe -i "http://127.0.0.1:8088/?id=1%20OR%201=1"

Write-Host ""
Write-Host "Recent WAF logs:"
docker compose logs --tail=50 waf
