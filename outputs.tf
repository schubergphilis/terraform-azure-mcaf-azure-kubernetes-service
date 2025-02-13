output "kubernetes_host_ip" {
  value = azurerm_kubernetes_cluster.main.kube_config[0].host
}