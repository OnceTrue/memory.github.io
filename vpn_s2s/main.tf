terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "RG" {
  name     = "${var.resource_prefix}-RG"
  location = var.location
}

resource "azurerm_virtual_network" "Vnet" {
  name                = "${var.resource_prefix}-Vnet"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  address_space       = var.Subnet_ip_address
}
resource "azurerm_subnet" "VSubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.Vnet.name
  address_prefixes     = ["40.10.0.0/27"]
}
resource "azurerm_subnet" "VSubnet2" {
  name                 = "etc"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.Vnet.name
  address_prefixes     = ["40.10.1.0/24"]
}
resource "azurerm_local_network_gateway" "To_Onpremise" {
  name                = "To_onpremise"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  gateway_address     = "168.62.225.23"
  address_space       = ["61.100.14.32/27", 
                         "192.0.142.0/24", 
                         "192.100.142.0/24", 
                         "172.16.39.0/24" ]
                        
}

resource "azurerm_public_ip" "VPN_Pip" {
  name                = "VPN_Pip"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "VPN" {
  name                = "Woc_VPN"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  type     = "VPN"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"
 
  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.VPN_Pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.VSubnet.id
  }
}

resource "azurerm_virtual_network_gateway_connection" "Connect" {
  name                = "VPN_Connect"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.VPN.id
  local_network_gateway_id   = azurerm_local_network_gateway.To_Onpremise.id
   ipsec_policy {
      dh_group = "DHGroup2048"
      ike_encryption = "AES128"
      ike_integrity = "SHA256"
      ipsec_encryption = "AES128"
      ipsec_integrity = "SHA256"
      pfs_group = "PFS2048"
      sa_lifetime = "28800"
      sa_datasize = "102400000"
  }
  shared_key = "ftwIi+q8FVX3A+2IswU7TfRBVbgYZGQ3Xm/1sOBE6YA="
}