$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$performanceDir = Join-Path $projectRoot "performance"
$backendSummary = Join-Path $performanceDir "backend-summary.json"
$wafSummary = Join-Path $performanceDir "waf-summary.json"

function Run-K6([string]$baseUrl, [string]$hostHeader, [string]$summaryFile) {
    $envArgs = @(
        "-e", "BASE_URL=$baseUrl",
        "-e", "VUS=10",
        "-e", "DURATION=20s",
        "-e", "SLEEP_SECONDS=0.1"
    )

    if ($hostHeader) {
        $envArgs += @("-e", "HOST_HEADER=$hostHeader")
    }

    docker compose --profile perf run --rm `
        $envArgs `
        k6 run --summary-export "/scripts/$summaryFile" /scripts/load-test.js
}

function Show-Summary([string]$label, [string]$path) {
    $data = Get-Content $path -Raw | ConvertFrom-Json

    [PSCustomObject]@{
        Target = $label
        AvgMs = [math]::Round($data.metrics.http_req_duration.avg, 2)
        P95Ms = [math]::Round($data.metrics.http_req_duration.'p(95)', 2)
        ReqRate = [math]::Round($data.metrics.http_reqs.rate, 2)
        FailRate = [math]::Round($data.metrics.http_req_failed.value, 4)
    }
}

Write-Host "Running backend baseline test..."
Run-K6 "http://backend:80" "" "backend-summary.json"

Write-Host ""
Write-Host "Running WAF-fronted test..."
Run-K6 "http://waf:8080" "localhost" "waf-summary.json"

Write-Host ""
Write-Host "Performance Summary"
$backend = Show-Summary "backend-direct" $backendSummary
$waf = Show-Summary "waf-fronted" $wafSummary
$backend, $waf | Format-Table -AutoSize

Write-Host ""
Write-Host ("Approximate added average latency: {0} ms" -f [math]::Round(($waf.AvgMs - $backend.AvgMs), 2))
Write-Host ("Approximate added p95 latency: {0} ms" -f [math]::Round(($waf.P95Ms - $backend.P95Ms), 2))

Write-Host ""
Write-Host "Summary files:"
Write-Host $backendSummary
Write-Host $wafSummary
