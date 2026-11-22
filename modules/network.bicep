param location string
param environment string
param projectName string

var vnetName = 'vnet-${projectName}-${environment}'

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location
  tags: {
    Environment: environment
    Project: projectName
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}

resource frontendNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-frontend-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
  }
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTPS'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource backendNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-backend-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
  }
  properties: {
    securityRules: [
      {
        name: 'Allow-Frontend-To-Backend'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '8080'
          sourceAddressPrefix: '10.0.1.0/24'
          destinationAddressPrefix: '10.0.2.0/24'
        }
      }
      {
        name: 'Deny-Other-Inbound'
        properties: {
          priority: 200
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource databaseNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-database-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
  }
  properties: {
    securityRules: [
      {
        name: 'Allow-Backend-To-Database'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3306'
          sourceAddressPrefix: '10.0.2.0/24'
          destinationAddressPrefix: '10.0.3.0/24'
        }
      }
      {
        name: 'Deny-Other-Inbound'
        properties: {
          priority: 200
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource frontendRouteTable 'Microsoft.Network/routeTables@2024-05-01' = {
  name: 'rt-frontend-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
  }
  properties: {
    routes: []
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
  parent: vnet
  name: 'subnet-frontend'
  properties: {
    addressPrefix: '10.0.1.0/24'
    networkSecurityGroup: {
      id: frontendNsg.id
    }
    routeTable: {
      id: frontendRouteTable.id
    }
  }
}

resource backendSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
  parent: vnet
  name: 'subnet-backend'
  properties: {
    addressPrefix: '10.0.2.0/24'
    networkSecurityGroup: {
      id: backendNsg.id
    }
  }
}

resource databaseSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
  parent: vnet
  name: 'subnet-database'
  properties: {
    addressPrefix: '10.0.3.0/24'
    networkSecurityGroup: {
      id: databaseNsg.id
    }
  }
}

output vnetId string = vnet.id
output subnetId string = subnet.id
output backendSubnetId string = backendSubnet.id
