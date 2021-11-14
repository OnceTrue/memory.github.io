variable "location" {
    type = string
}

variable "resource_prefix" {
    type = string
}
# Subnet으로 사용할 주소 공간을 지정합니다.
variable "Subnet_ip_address" {
    default = ["40.10.0.0/16"]
}
