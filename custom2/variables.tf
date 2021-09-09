variable "node_location" {
    type = string
}
variable "resource_prefix"{
    type = string
}
variable "node_address_space" {
    default = ["121.0.0.0/8"]
}
variable "node_address_prefix"{
    default = "121.1.0.0/16"
}
variable "node_count" {
    type = number
}
variable "vhd_uri" {
    type = string
}