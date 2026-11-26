param location string
@description('Deployment environment')
@allowed([
  'dev'
  'prod'
])
param environment string
param projectName string

var storageAccountName = 'st${environment}${uniqueString(resourceGroup().id, projectName, environment)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_GRS'
  }
  kind: 'StorageV2'
  tags: {
    Environment: environment
    Project: projectName
  }
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

output storageAccountId string = storageAccount.id
output generatedName string = storageAccountName
