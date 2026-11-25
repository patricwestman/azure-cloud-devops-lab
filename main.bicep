param location string
@description('Deployment environment')
@allowed([
    'dev'
    'prod'
])
param environment string
param projectName string
@description('SSH public key for the backend VM')
@secure()
param adminSshPublicKey string

module storage './modules/storage.bicep' = {
    name: 'storageDeployment'
    params: {
        location: location
        environment: environment
        projectName: projectName

    }
}

module network 'modules/network.bicep' = {
    name:'networkDeployment'
    params: {
        environment: environment
        location: location
        projectName: projectName
    }
}

module compute './modules/compute.bicep' = {
    name: 'computeDeployment'
    params: {
        location: location
        environment: environment
        projectName: projectName
        backendSubnetId: network.outputs.backendSubnetId
        adminSshPublicKey: adminSshPublicKey
    }
}

output storageAccountId string = storage.outputs.storageAccountId
output generatedName string = storage.outputs.generatedName
output vnetId string = network.outputs.vnetId
output subnetId string = network.outputs.subnetId
