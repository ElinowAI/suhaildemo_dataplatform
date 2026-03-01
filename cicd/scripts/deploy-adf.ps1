<#
.SYNOPSIS  Deploy ADF assets to target environment.
.PARAMETER Environment  dev | test | uat | prod
.PARAMETER ArtifactPath Path to build_output/
.EXAMPLE   ./deploy-adf.ps1 -Environment dev -ArtifactPath ./artifact/unzipped/build_output
#>
param(
    [Parameter(Mandatory=$true)][ValidateSet("dev","test","uat","prod")][string]$Environment,
    [Parameter(Mandatory=$true)][string]$ArtifactPath
)
$VarsFile = "$PSScriptRoot/../variables/$Environment.yml"
if (-not (Test-Path $VarsFile)) { Write-Error "Variables not found: $VarsFile"; exit 1 }
Write-Host "Loading variables from $VarsFile"
$AdfPath = Join-Path $ArtifactPath "adf"
if (-not (Test-Path $AdfPath)) { Write-Error "ADF assets not found at $AdfPath"; exit 1 }
$Files = Get-ChildItem -Path $AdfPath -Recurse -Filter "*.json"
Write-Host "Deploying $($Files.Count) ADF asset(s) to adf-dataplatform-$Environment..."
foreach ($f in $Files) {
    Write-Host "  [DEMO] $($f.Name) OK"
    # Real: az datafactory pipeline create --resource-group rg-dataplatform-$Environment
    #         --factory-name adf-dataplatform-$Environment --pipeline-name $f.BaseName
}
Write-Host "ADF deployment to $Environment completed"
