provider azurerm {
    version = "~>2.0"
        features {}
}
variable "prefix" {
  default = "wctf"
}
resource "azurerm_resource_group" "main" {
  name = "${var.prefix}-resources"
  location = "koreacentral"
}
resource "azurerm_virtual_network" "main" { 
  name = "${var.prefix}-network"
  address_space = [ "150.0.0.0/16" ]
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}
resource "azurerm_subnet" "interanl" {
  name = "internal"
  resourec_group_name = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = ["150.0.1.0/24"]
}
resource "azurerm_network_interface" "main" {
  name = "${var.prefix}-nic"
  loaction = azurerm_resource_group.main.location
  resourec_group_name = azurerm_resource_group.main.name
  ip_configuration {
    name = "wooc"
    subnet_id = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"

  }
}

resource "azurerm_virtual_machine" "main" {
  name = "${var.prefix}-vm"
  loaction = azurerm_resource_group.main.location
  resourec_group_name = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size = "Standard_DS1_v2"

storage_os_disk {
  name = "${var.prefix}-disk"
  caching = "ReadWrite"
  createoption = "FromImage"
  managed_disk_type = "Standard_LRS"
}
os_profile {
  computer_name = "${var.prefix}-wc"
  admin_username = "AzureUser"
  admin_password = "AzureUser123456"
}
os_profile_linux_config {
  disable_password_authentication =false
}
tags = {
  enviroment = "wc-tf"
  }
}