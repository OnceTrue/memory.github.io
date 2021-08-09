provider azurerm {
    version = "~>2.0"
        features {}
}
locals {
  resource_list = ["a","b"]
}
resource "azurerm_resource_group" "RG" {
  count = "${length(local.resource_list)}"
  name = "${local.resource_list["${count.index}"]}"
  location = "korea central"
}
