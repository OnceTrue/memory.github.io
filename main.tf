provider "azurerm" {
    version = "~>2.0"
        features {}
}
resource "azurerm_resource_group" "li_rg" {
    name = "${var.resource_prefix}-RG"
    location = var.node_location
}
resource "azurerm_virtual_network" "li_vnet" {
    name = "${var.resource_prefix}-vnet"
    resource_group_name = azurerm_resource_group.li_rg.name
    location = var.node_location
    address_space = var.node_address_space
}
resource "azurerm_subnet" "li_sub" {
    name = "${var.resource_prefix}-sub"
    resource_group_name = azurerm_resource_group.li_rg.name
    virtual_network_name = azurerm_virtual_network.li_vnet.name
    address_prefix = var.node_address_prefix
}
resource "azurerm_network_interface" "li_nic" {
    count = var.node_count
    name = "${var.resource_prefix}-${format("%02d",count.index)}-NIC"
    location = var.node_location
    resource_group_name = azurerm_resource_group.li_rg.name
    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.li_sub.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_network_security_group" "li_nsg" {
    name = "${var.resource_prefix}-nsg"
    loaction = azurerm_resource_group.li_rg.location
    resource_group_name = azurerm_resource_group.li_rg.name
    security_rule {
        name = "Inbound"
        priority = 100
        direction = "Inbound"
        access = "Allow"
        protocol = "SSH"
        source_port_range = "*"
        destination_port_range = "*"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_subnet_network_security_group_association" "li_subnet_nsg_association" {
    subnet_id = azurerm_subnet.li_sub.id
    network_security_group_id = azurerm_network_security_group.li_nsg.id
}
resource "azurerm_virtual_machine" "li-vm" {
    count = var.node_count
    name = "${var.resource_prefix}-${format("%02d",count.index)}"
    location = azurerm_resource_group.li_rg.location
    resource_group_name = azurerm_resource_group.li_rg.name
    network_interface_ids = [element(azurerm_network_interface.li_nic.*.id, count.index)]
    vm_size = "Standard_B1s"
    delete_os_disk_on_termination = true
    storage_image_reference {
        publisher = "UbuntuServer"
        offer = "UbuntuServer"
        sku = "16.04-LTS"
        version = "latest" 
    }
    storage_os_disk{
        name = "lidisk-${count.index}"
        caching = "ReadWrite"
        create_option = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile{
        computer_name = "lidd"
        admin_username = "AzureUser"
        admin_password = "Eogksalsrnr1!"
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
}
