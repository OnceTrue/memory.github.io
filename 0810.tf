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
  resource_group_name = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = ["150.0.1.0/24"]
}
resource "azurerm_public_ip" "wcpip" {
  name = "${var.prefix}-Pip"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  allocation_method = "Dynamic"
  idle_timeout_in_minutes = 30
  tags = {
    enviroment = "public-ip"
  }
}
resource "azurerm_network_interface" "main" {
  name = "${var.prefix}-nic"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  ip_configuration {
    name = "wooc"
    subnet_id = azurerm_subnet.interanl.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.wcpip.id

  }
}
resource "azurerm_network_security_group" "wcnsg" {
  name = "${var.prefix}-nsg"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  security_rule {
    name = "ssh"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
   }
security_rule {
    name = "port80"
    priority = 110
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"
}
}
resource "azurerm_network_interface_security_group_association" "wcnsg" {
  network_interface_id = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.wcnsg.id
} 
resource "azurerm_virtual_machine" "wcvm" {
  name = "${var.prefix}-vm"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size = "Standard_DS1_v2"

storage_image_reference {
  publisher = "Canonical"
  offer = "UbuntuServer"
  sku = "16.04-LTS"
  version = "latest" 
}
storage_os_disk {
  name = "${var.prefix}-woocdisk"
  caching = "ReadWrite"
  create_option = "FromImage"
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