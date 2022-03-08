@description('User name for the Virtual Machine.')
param adminUsername string = 'adminuser'

@description('Password for the Virtual Machine.')
@secure()
param adminPassword string

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsLabelPrefix string = 'ddvm-${uniqueString(resourceGroup().id)}'

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
@allowed([
  '2019-Datacenter'
  '2016-Datacenter'
  '2016-Datacenter-Server-Core'
  '2016-Datacenter-Server-Core-smalldisk'
  '2016-Datacenter-smalldisk'
  '2016-Datacenter-with-Containers'
  '2016-Nano-Server'
])
param OSVersion string = '2019-Datacenter'

@description('The number of dataDisks to be returned in the output array.')
@minValue(0)
@maxValue(16)
param numberOfDataDisks int = 2

@description('Location for all resources.')
param location string = resourceGroup().location

@description('description')
param vmSize string = 'Standard_D8s_v3'

var imagePublisher = 'MicrosoftWindowsServer'
var imageOffer = 'WindowsServer'
var nicName = 'myVMNic'
var addressPrefix = '10.0.0.0/16'
var subnetName = 'Subnet1'
var subnetPrefix = '10.0.0.0/24'
var publicIPAddressName = 'vmPublicIP'
var vmName_var = 'VMStorageTest'
var virtualNetworkName = 'MyVNET'
//var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
var networkSecurityGroupName = 'default-NSG'


module mynetwork 'network.bicep' = {
  name: 'Vmnetwork'
  params: {
    location: location
    dnsLabelPrefix: dnsLabelPrefix
    nicName: nicName
    addressPrefix: addressPrefix
    subnetName: subnetName
    subnetPrefix: subnetPrefix
    publicIPAddressName: publicIPAddressName
    virtualNetworkName: virtualNetworkName
    // var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName_var, subnetName)
    networkSecurityGroupName: networkSecurityGroupName
  }
}


resource vmName 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vmName_var
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName_var
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
      dataDisks: [for j in range(0, numberOfDataDisks): {
        diskSizeGB: 8
        lun: j
        name: 'Datadisk${j}'
        createOption: 'Empty'
        deleteOption: 'Delete'
      }]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: mynetwork.outputs.nicId
        }
      ]
    }
  }
}

output hostname string = mynetwork.outputs.fqdn
