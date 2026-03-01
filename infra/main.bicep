// main.bicep - Data Platform Infrastructure
// Usage: az deployment sub create --location eastus --template-file infra/main.bicep --parameters environment=dev

targetScope = 'subscription'

@description('Target environment: dev | test | uat | prod')
@allowed(['dev','test','uat','prod'])
param environment string

@description('Azure region')
param location string = 'eastus'

@description('Project prefix for all resource names')
param projectName string = 'dataplatform'

var rgName      = 'rg-${projectName}-${environment}'
var adfName     = 'adf-${projectName}-${environment}'
var storageName = 'sta${projectName}${environment}'
var sqlName     = 'sql-${projectName}-${environment}'
var kvName      = 'kv-${projectName}-${environment}'

var tags = { environment: environment, project: projectName, managedBy: 'bicep' }

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName; location: location; tags: tags
}

output resourceGroup string = rg.name
output adfName        string = adfName
output storageName    string = storageName
output sqlServerFqdn  string = '${sqlName}.database.windows.net'
output keyVaultUri    string = 'https://${kvName}.vault.azure.net'
