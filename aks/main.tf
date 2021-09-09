provider "azurerm" {
    version = "~>2.0"
    features {
      
    }
}
provider "helm" {
    version = "1.2.2"
    kubernetes {
      host= azurerm_kubernetes_cluster.clouster.kube_config[0].host

    
    clinet_key = base64decode(azurerm_kubernetes_cluster.cluster.kubeconfig[0].client_key)
    client_certificate = base64decode(azurerm_kubernetes_cluster.cluster.kube_config[0].client_certificate)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate)
    load_config_file = false
    }
}

resource "azurerm_resourece_group" "wc-rg"{
    name = "${var.prefix}-rg"
    loaction = var.location
}

resource "azurerm_kubernetes_cluster" "wc-cluster"{
    name = "${var.prefix}-aks"
    location = var.location
    dns_prefix = "${var.prefix}-dns"
    resource_group_name = azurerm_resourece_group.wc-rg.name
    kubernetes_version = "1.18.2"
    default_node_pool {
      name = "${var.prefix}-node"
      node_count = "1"
      vm_size = "Standard_B1ms"
    }
    identity {
        type = "SystemAssigned"
    }
}
resource "helm_release" "wc-ingress" {
    name = "${var.prefix}-ing"
    chart = "stable/nginx-ingress"
    set {
        name = "rbac.create"
        value = "true"
    }
}