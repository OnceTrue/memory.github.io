param namePrefix string = 'woc'
param location string = resourceGroup().location
param subnetId string
param ubuntuOsVersion string = '18.04-LTS'
param osDiskType string = 'Standard_LRS'
param vmSize string = 'Standarad_B1s'

var vmName = '${namePrefix}${uniqueString(resourceGroup().id)}'
var password = 'Eogksalsrnr1!'
var username = 'AzureUser'

module nic './nic.bicep' = {
  name: '${vmName}-nic'
  params: {
    namePrefix: '${vmName}-hdd'
    subnetId: subnetId
  }
}

resource wcvm 'Microsoft.Compute/virtualMachines@2021-04-01' = {
  name: vmName
  location: location
  zones : [
    '1'
  ]
  properties:{
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile:{
      osDisk: {
        createOption:'FromImage'
        managedDisk:{
          storageAccountType:osDiskType
        }
      }
      imageReference: {
        publisher:'Canonical'
        offer:'UbuntuServer'
        sku: ubuntuOsVersion
        version: 'latest'
      }
    }
    osProfile: {
      computerName:vmName
      adminUsername: username
      adminPassword:password
    }
    networkProfile:{
      networkInterfaces:[
        {
          id: nic.outputs.nicID
        }
      ]
    }
  }

}
output id string = wcvm.id
