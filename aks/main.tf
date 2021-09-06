provider "azurerm" {
    features{}
}
resource "azurerm_resource_group" "wc-g" {
    name = "${var.prefix}-k8s"
    location = var.location
}
resource "azurerm_log_analytics_workspace_name_suffix" {
    byte_length = 8
}
resource "azurerm_log_analytics_workspace" "wc-log"  {
    name = "${var.prefix}-log"
    location = var.location
    resource_group_name = azurerm_resource_group.wc-g.name
    sku = var.log_analytics_workspace_sku
}
resource "azurerm_log_analytics_solution" "wc-logsol" {
    solution_name = "${var.prefix}-sol"
    location = var.location
    resource_group_name = azurerm_resource_group.wc-g.name
    workspace_name = azurerm_log_analytics_workspace.wc-log.name
    workspace_resource_id = azurerm_log_analytics_workspace.wc-log.id

    plan {
      publisher = "Microsoft"
      product = "OMS"
    }
}
//https://docs.microsoft.com/ko-kr/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks
resource "azurerm_kubernetes_cluster" "wc-aks" {
    name = "${var.prefix}-aks"
    location = var.location
    resource_group_name = azurerm_resource_group.wc-g.name
    dns_prefix = "${var.prefix}-aksdns"
    
    default_node_pool {
        name = "wc"
        node_count = 1
        vm_size = "Standard_B1ms"
    }
    identity {
        type = "SystemAssigned"
    }
    addon_profile {
        aci_connector_linux {
            enabled = false
        }
        azure_policy {
            enabled = false
        }
        http_application_routing {
            enabled = false
        }
        kube_dashboard {
            enabled = true
        }
        oms_agent {
            enabled = false
        }
    }
}