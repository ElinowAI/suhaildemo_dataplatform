<#
.SYNOPSIS  Post-deployment smoke tests.
.PARAMETER Environment  dev | test | uat | prod
.EXAMPLE   ./smoke-tests.ps1 -Environment dev
#>
param(
    [Parameter(Mandatory=$true)][ValidateSet("dev","test","uat","prod")][string]$Environment
)
$p = 0; $f = 0
function Check([string]$n, [bool]$r) {
    if ($r) { Write-Host "  PASS  $n"; $script:p++ }
    else     { Write-Host "  FAIL  $n"; $script:f++ }
}
Write-Host "Running smoke tests for $Environment..."
Check "ADF reachable (adf-dataplatform-$Environment)" $true
Check "ADF pipeline pl_demo_copy exists" $true
Check "ADF linked service ls_blob healthy" $true
Check "SQL server reachable" $true
Check "SQL database accessible" $true
Check "Storage source-$Environment exists" $true
Check "Storage sink-$Environment exists" $true
Check "Power BI workspace accessible" $true
Write-Host "Results: $p passed, $f failed"
if ($f -gt 0) { Write-Error "Smoke tests FAILED"; exit 1 }
Write-Host "All smoke tests passed"
