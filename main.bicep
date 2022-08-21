@description('Resource Group to deploy resource in')
param location string = resourceGroup().location

@description('SSH UserName')
@minLength(2)
@maxLength(28)
param vmAdminUsername string

@description('Password for SSH')
@secure()
@minLength(12)
@maxLength(72)
param vmAdminPassword string

@description('Allowed IP for T-Pot administration')
@minLength(7)
@maxLength(16)
param nsgAllowedIP string

@description('Size of VM')
param vmSize string = 'Standard_B4ms'


var virtualMachineName = 'honey'
var ResourceNamingSuffix = 'honeypot-test'
var storageAccountResourceName = '${virtualMachineName}st01'
var PublicIPResourceName = 'pip-${ResourceNamingSuffix}'
var NetworkSecurityGroupResourceName = 'nsg-${ResourceNamingSuffix}'
var virtualNetworkResourceName = 'vnet-${ResourceNamingSuffix}'
var virtualMachineResourceName = 'vm-${virtualMachineName}-${ResourceNamingSuffix}'
var nicResourceName = 'nic-${virtualMachineName}-${ResourceNamingSuffix}'
var vmPublisher = 'debian'
var vmOffer = 'debian-11'
var vmSku = '11-gen2'
var vmVersion = 'latest'
var addressPrefix = '10.0.0.0/16'
var subnetName = 'Subnet'
var subnetPrefix = '10.0.0.0/24'
var subnetReference = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkResourceName, subnetName)


resource StorageAccountResource 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  name: storageAccountResourceName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource PublicIPResource 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
  name: PublicIPResourceName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource NetworkSecurityGroupResource 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
  name: NetworkSecurityGroupResourceName
  location: location
  properties: {
    securityRules: [
      {
        name: 'TPOT-allow-management'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: nsgAllowedIP
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '64294-64297'
        }
      }

      {
        name: 'TPOT-allow-honeypot'
        properties: {
          priority: 2000
          access: 'Allow'
          direction: 'Inbound'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRanges: [
            '0-64293'
            '64298-65535'
          ]
          destinationAddressPrefix: '*'
          destinationPortRanges: [
            '0-64293'
            '64298-65535'
          ]
        }
      }

    ]
  }
}

resource virtualNetworkResouce 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: virtualNetworkResourceName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: NetworkSecurityGroupResource.id
          }
        }
      }
    ]
  }
}

resource nicResource 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: nicResourceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: PublicIPResource.id
          }
          subnet: {
            id: subnetReference
          }
        }
      }
    ]
  }
  dependsOn: [
    virtualNetworkResouce
  ]
}

resource virtualMachineResource 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: virtualMachineResourceName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: virtualMachineName
      adminUsername: vmAdminUsername
      adminPassword: vmAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: vmPublisher
        offer: vmOffer
        sku: vmSku
        version: vmVersion
      }
      osDisk: {
        name: '${virtualMachineResourceName}-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicResource.id
        }
      ]
    }
  }
  dependsOn: [
    StorageAccountResource
  ]
}

resource virtualMachineResourceInstallTPot 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  parent: virtualMachineResource
  name: 'install_tpot'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      skipDos2Unix: false
      fileUris: [
        'https://raw.githubusercontent.com/rirofal/Azure-T-Pot-Bicep/main/install_tpot.sh'
      ]
    }
    protectedSettings: {
      commandToExecute: 'sh install_tpot.sh'
    }
  }
}

output VMName string = virtualMachineResourceName
output PublicIpName string = PublicIPResourceName
