# output "kubernetes_host_ip" {
#   value = azurerm_kubernetes_cluster.this.kube_config[0].host
# }

output "resource" {
  value = azurerm_kubernetes_cluster.this
}

output "resource_id" {
  value = azurerm_kubernetes_cluster.this.id
}

output "name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "system_assigned_mi_principal_id" {
  description = "The system assigned managed identity principal ID of the parent resource."
  value       = try(azurerm_kubernetes_cluster.this.identity[0].principal_id, null)
}

output "kube_admin_config" {
  value = azurerm_kubernetes_cluster.this.kube_admin_config
}
