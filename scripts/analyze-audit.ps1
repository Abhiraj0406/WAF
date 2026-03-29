$ErrorActionPreference = "Stop"

$logPath = Join-Path $PSScriptRoot "..\\logs\\modsec_audit.log"
$resolvedLogPath = Resolve-Path $logPath

if (-not (Test-Path $resolvedLogPath)) {
    throw "Audit log not found at $logPath"
}

$entries = Get-Content $resolvedLogPath | Where-Object { $_.Trim() } | ForEach-Object {
    try {
        $_ | ConvertFrom-Json
    } catch {
        $null
    }
} | Where-Object { $_ -ne $null }

if (-not $entries) {
    Write-Host "No audit entries found."
    exit 0
}

$messages = foreach ($entry in $entries) {
    foreach ($message in $entry.transaction.messages) {
        [PSCustomObject]@{
            Time    = $entry.transaction.time_stamp
            Uri     = $entry.transaction.request.uri
            RuleId  = $message.details.ruleId
            Message = $message.message
            Severity = $message.details.severity
        }
    }
}

Write-Host ""
Write-Host "Top Rule Hits"
$messages |
    Group-Object RuleId, Message |
    Sort-Object Count -Descending |
    Select-Object -First 10 |
    Format-Table Count, Name -AutoSize

Write-Host ""
Write-Host "Top Targeted URIs"
$entries |
    Group-Object { $_.transaction.request.uri } |
    Sort-Object Count -Descending |
    Select-Object -First 10 |
    Format-Table Count, Name -AutoSize

Write-Host ""
Write-Host "Recent Security Events"
$messages |
    Select-Object -Last 10 |
    Format-Table Time, RuleId, Message, Uri -AutoSize
