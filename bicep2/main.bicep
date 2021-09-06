param virtualMachineSize string = 'Standard_b1ms'
param adminUsername string = 'AzureUser'
param adminPassword string = 'Eogksalsrnr1!'
@allowed([
  'Standard_LRS'
  'Premium_LRS'
])
param storageAccountType string = 'Standard_LRS'
param location string = resourceGroup().location

var virtualMachineName = 'wooc-vm'
var nicname = 'wc-nic'
var virtualNetworkName = 'wc-vnet'
var subnetName = 'wc-sub'
var publicipAddressName = 'wc-pip'
var diagStorageAccountName = 'diags${uniqueString(resourceGroup().id)}'
var networkSecurityGroupName = 'wc-nsg'
var loadname = 'wclb'

//가상머신 생성
resource vm 'Microsoft.Compute/virtualMachines@2021-04-01'= {
  name : virtualMachineName
  location: location
  properties: {
    osProfile: {
      computerName:virtualMachineName
      adminPassword:adminPassword
      adminUsername: adminUsername
      windowsConfiguration: {
        provisionVMAgent: true
      }
    }
    hardwareProfile:{
      vmSize:virtualMachineSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version:'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile:{
      networkInterfaces:[
        {
          properties: {
            primary:true
          }
          id:nic.id
        }
      ]
    }
    diagnosticsProfile:{
      bootDiagnostics:{
        enabled:true
        storageUri:diagsAccount.properties.primaryEndpoints.blob
      }
    }
  }
}

resource diagsAccount 'Microsoft.Storage/storageAccounts@2021-04-01'= {
  name:diagStorageAccountName
  location:location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: networkSecurityGroupName
  location:location
  properties: {
    securityRules:[
      {
      name: '3389-on'
      properties: {
        priority: 100
        sourceAddressPrefix: '*'
        protocol: 'Tcp'
        destinationPortRange: '3389'
        access:'Allow'
        direction: 'Inbound'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
      }
    }
   ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name:virtualNetworkName
  location:location
  properties:{
    addressSpace:{
      addressPrefixes:[
        '100.0.0.0/8'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties:{
          addressPrefix: '100.1.0.0/16'
          networkSecurityGroup:{
            id:nsg.id
          }
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01'= {
  name:nicname
  location:location
  properties: {
    ipConfigurations:[
      {
        name: 'wc-ipcon'
        properties:{
          subnet:{
          id: resourceId('Microsoft.Netwrok/virtualNetworks/subnets', vnet.name, subnetName)
        }
        privateIPAllocationMethod:'Dynamic'
        publicIPAddress: {
          id: wcpip.id
        }
      }
    }
    ]
    networkSecurityGroup:{
      id:nsg.id
     }
    }
  }


resource wcpip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: publicipAddressName
  location: location
  properties: {
    publicIPAllocationMethod:'Dynamic'
  }
}
resource wclb 'Microsoft.Network/loadBalancers@2021-02-01' ={
  name: loadname
  location:location
  sku: {
    name:'Standard'
    tier: 'Regional'
  }
  properties:{
    frontendIPConfigurations: [
      {
        name: wcpip
        properties: {
         privateIPAllocationMethod: 'Dynamic'
         subnet: {
           id: vnet.id
         }
        }
      }
    ]
    backendAddressPools:[
      { 
        id: 
        name: 'wc-back'
        properties:{
          loadBalancerBackendAddresses:[
            {
              name:
            }
          ]
        }
      }
    ]
  }
}
