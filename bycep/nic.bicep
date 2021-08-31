param namePrefix string = 'unique'
param location string = resourceGroup().location
param subnetId string
param privateIPAddress string = '100.0.0.0'

var vmnae = '${namePrefix}${uniqueString(resourceGroup().id)}'

resource wc_nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: vmnae
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'wcip'
        properties: {
          privateIPAddress:privateIPAddress
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          primary:true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
}

output nicID string = wc_nic.id
