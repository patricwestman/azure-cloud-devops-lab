param location string
param environment string
param projectName string
param backendSubnetId string

@description('Administrator username for the Ubuntu VM')
param adminUsername string = 'azureuser'

@description('SSH public key used for authentication')
@secure()
param adminSshPublicKey string

resource backendNic 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: 'nic-backend-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig-backend'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: backendSubnetId
          }
        }
      }
    ]
  }
}

resource backendVm 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: 'vm-backend-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s_V2'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
      }
    }
    osProfile: {
      computerName: 'backend-${environment}'
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: adminSshPublicKey
            }
          ]
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: backendNic.id
        }
      ]
    }
  }
}
