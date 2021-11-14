provider "azurerm" {
        features {}
}
##리소스 그룹 생성
resource "azurerm_resource_group" "li_rg" {
    name = "${var.resource_prefix}-RG"
    location = var.node_location
}
## NSG 생성 접속 22 , http 80포트 열음
resource "azurerm_network_security_group" "li_nsg" {
    name = "${var.resource_prefix}-nsg"
    location = var.node_location
    resource_group_name = azurerm_resource_group.li_rg.name
    security_rule {
        name = "Inbound_ssh"
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
        name = "Inbound_http"
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
## NSG 붙이기
resource "azurerm_subnet_network_security_group_association" "li_subnet_nsg_association" {
    subnet_id = azurerm_subnet.li_sub.id
    network_security_group_id = azurerm_network_security_group.li_nsg.id
}
## 가상머신 생성
resource "azurerm_virtual_machine" "li-vm" {
    count = var.node_count
    name = "0${format("%03d",count.index)}"
    #{count.index+1}를 하면 숫자를 이 후로 설정 할 수 있음
    location = var.node_location
    resource_group_name = azurerm_resource_group.li_rg.name
    network_interface_ids = [element(azurerm_network_interface.li_nic.*.id, count.index)]
    vm_size = "Standard_B1ms"
    delete_os_disk_on_termination = true
    storage_image_reference {
        ## 커스텀 이미지의 리소스 ID 지정
        id = var.vhd_uri
    }
    storage_os_disk{
        name = "lidisk-${count.index}"
        caching = "ReadWrite"
        create_option = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile{
        #컴퓨터 이름 붙이기
        computer_name = "0${format("%03d",count.index)}"
        admin_username = "AzureUser"
        admin_password = "Eogksalsrnr1!"
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
}
## Vnet 생성
resource "azurerm_virtual_network" "li_vnet" {
    name = "${var.resource_prefix}-vnet"
    resource_group_name = azurerm_resource_group.li_rg.name
    location = var.node_location
    address_space = var.node_address_space
}
## 서브넷 생성
resource "azurerm_subnet" "li_sub" {
    name = "${var.resource_prefix}-sub"
    resource_group_name = azurerm_resource_group.li_rg.name
    virtual_network_name = azurerm_virtual_network.li_vnet.name
    address_prefixes = var.node_address_prefix
}
## 네트워크 인터페이스 생성
resource "azurerm_network_interface" "li_nic" {
    count = var.node_count
    name = "${var.resource_prefix}-${format("%03d",count.index)}-NIC"
    location = var.node_location
    resource_group_name = azurerm_resource_group.li_rg.name
    ip_configuration {
        #여기 이름은 나중에 붙일 때 이 이름으로 붙임
        name = "internal${format("%03d",var.node_count)}"
        subnet_id = azurerm_subnet.li_sub.id
        private_ip_address_allocation = "Dynamic"
    }
}

## 퍼블릭 IP를 NIC에 넣어야 하는건가? 표준은Dynamic으로 설정 하면 안됨 Global 문제로 생성이 안되고 Regional로 됨
## waiting for creation/update of Public Ip Address: (Name "LB-Pip" / Resource Group "linuxnode-RG"): Code="VipAllocationFailedWithVipRangeNotFound" Message="No matching VIP range. Please contact support for more details." Details=[]
## 공인 IP 생성
resource "azurerm_public_ip" "li_pip" {
    name = "LB-Pip"
    resource_group_name = azurerm_resource_group.li_rg.name
    location = var.node_location
    allocation_method = "Static"
    sku = "standard"
    sku_tier = "Regional"
    availability_zone = "No-Zone"
}
## 로드밸런서 생성
resource "azurerm_lb" "li_lb" {
    resource_group_name = azurerm_resource_group.li_rg.name
    name = "li-lb"
    location = var.node_location
    sku = "standard"
    frontend_ip_configuration {
        name = "front-ip"
        public_ip_address_id = azurerm_public_ip.li_pip.id
    }
}
## 로드밸런서 백엔드풀 생성
resource "azurerm_lb_backend_address_pool" "li_back" {
    loadbalancer_id = azurerm_lb.li_lb.id
    name = "li-back"
}
## 백엔드풀에 가상머신 붙이기
resource "azurerm_network_interface_backend_address_pool_association" "li_backPooL" {
    count = var.node_count
    network_interface_id = element(azurerm_network_interface.li_nic.*.id, count.index)
    ip_configuration_name = "internal${format("%03d",var.node_count)}"
    backend_address_pool_id = azurerm_lb_backend_address_pool.li_back.id
}
## 로드밸런서 nat 룰 생성
resource"azurerm_lb_nat_rule" "li_nat_rule" {
    #여기서 Count를 해주어야 순서대로 붙음
    count = var.node_count
    resource_group_name = azurerm_resource_group.li_rg.name
    loadbalancer_id = azurerm_lb.li_lb.id
    name = "ssh-${count.index}"
    protocol = "tcp"
    frontend_port = "50${count.index}"
    backend_port = 22
    frontend_ip_configuration_name = "front-ip"
}
## nat룰에 네트워크인터페이스, 가상머신 붙이기
resource "azurerm_network_interface_nat_rule_association" "li_natrule_association" {
    count = var.node_count
    network_interface_id = element(azurerm_network_interface.li_nic.*.id, count.index)
    ip_configuration_name = "internal${format("%03d",var.node_count)}"
    nat_rule_id = element(azurerm_lb_nat_rule.li_nat_rule.*.id, count.index)
}
## 공인 IP 보기
output "PublicIP" {
  value = azurerm_public_ip.li_pip.ip_address
}

##A resource with the ID "/subscriptions/801d5b45-4c84-4353-a1ce-213384a016aa/resourceGroups/linuxnode-RG/providers/Microsoft.Network/publicIPAddresses/LB-Pip" already exists - to be managed via Terraform this resource needs to be imported into the State. Please see the resource documentation for "azurerm_public_ip" for more information.
##커스텀 이미지로 VM 생성하기