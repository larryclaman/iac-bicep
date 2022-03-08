param location string
param dnsLabelPrefix string

param nicName string 
param addressPrefix string = '10.0.0.0/16'
param subnetName string = 'Subnet1'
param subnetPrefix string = '10.0.0.0/24'
param publicIPAddressName string = 'vmPublicIP'
param publicIPAddressType string = 'Dynamic'
param virtualNetworkName string = 'MyVNET'
var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
param networkSecurityGroupName string = 'default-NSG'


resource publicIPAddressName_res 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: publicIPAddressType
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
}

resource networkSecurityGroupName_res 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource virtualNetworkName_res 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: virtualNetworkName
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
            id: networkSecurityGroupName_res.id
          }
        }
      }
    ]
  }
}

resource vmnicName 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddressName_res.id
          }
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
  }
  dependsOn: [
    virtualNetworkName_res
  ]
}

output nicId string = vmnicName.id 
output fqdn string = publicIPAddressName_res.properties.dnsSettings.fqdn
