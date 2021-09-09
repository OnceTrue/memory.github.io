output "kube_config" {
    value = azurerm_kubernetes_cluster.wc-cluster.kube_config_raw
}
