$ErrorActionPreference = "Stop"

$previousMode = $env:MODSEC_RULE_ENGINE

try {
    $env:MODSEC_RULE_ENGINE = "On"

    Write-Host "Recreating WAF in blocking mode..."
    docker compose up -d --force-recreate waf
    Start-Sleep -Seconds 15

    Write-Host ""
    Write-Host "Testing verification probe in blocking mode..."
    $response = curl.exe -sS -i -H "Host: localhost" "http://127.0.0.1:8088/?waf_probe=1"
    $responseText = ($response | Out-String)
    $responseText

    if ($responseText -notmatch "403 Forbidden") {
        throw "Expected blocking response 403, but probe was not blocked."
    }

    Write-Host ""
    Write-Host "Blocking mode verification passed."
}
finally {
    if ($null -eq $previousMode) {
        Remove-Item Env:MODSEC_RULE_ENGINE -ErrorAction SilentlyContinue
    } else {
        $env:MODSEC_RULE_ENGINE = $previousMode
    }

    Write-Host ""
    Write-Host "Restoring detection mode..."
    docker compose up -d --force-recreate waf | Out-Null
}
