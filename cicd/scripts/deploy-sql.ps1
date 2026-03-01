<#
.SYNOPSIS  Run SQL migrations using Expand/Contract pattern.
.PARAMETER Environment  dev | test | uat | prod
.EXAMPLE   ./deploy-sql.ps1 -Environment dev
#>
param(
    [Parameter(Mandatory=$true)][ValidateSet("dev","test","uat","prod")][string]$Environment
)
$Scripts = Get-ChildItem -Path "$PSScriptRoot/../../sql" -Filter "*.sql" | Sort-Object Name
if ($Scripts.Count -eq 0) { Write-Host "No SQL scripts found."; exit 0 }
Write-Host "Running $($Scripts.Count) SQL script(s) on db-dataplatform-$Environment..."
foreach ($s in $Scripts) {
    Write-Host "  [DEMO] $($s.Name) OK"
    # Real: Invoke-Sqlcmd -ServerInstance "sql-dataplatform-$Environment.database.windows.net"
    #         -Database "db-dataplatform-$Environment" -InputFile $s.FullName
}
Write-Host "SQL deployment to $Environment completed"
