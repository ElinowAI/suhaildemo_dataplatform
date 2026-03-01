<#
.SYNOPSIS  Publish Power BI datasets to target workspace.
.PARAMETER Environment  dev | test | uat | prod
.EXAMPLE   ./deploy-powerbi.ps1 -Environment dev
#>
param(
    [Parameter(Mandatory=$true)][ValidateSet("dev","test","uat","prod")][string]$Environment
)
$Reports = Get-ChildItem -Path "$PSScriptRoot/../../powerbi" -Filter "*.json"
Write-Host "Deploying $($Reports.Count) Power BI asset(s) to workspace-$Environment..."
foreach ($r in $Reports) {
    Write-Host "  [DEMO] $($r.Name) OK"
    # Real: POST https://api.powerbi.com/v1.0/myorg/groups/{workspaceId}/imports
}
Write-Host "Power BI deployment to $Environment completed"
