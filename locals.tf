locals {
  managed_identities = {
    this = var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) == 0 ? {
      type        = "SystemAssigned"
      resource_id = null
      } : {
      type        = "UserAssigned"
      resource_id = var.managed_identities.user_assigned_resource_ids
    }
  }
  user_assigned_identity = length(var.managed_identities.user_assigned_resource_ids) > 0 ? provider::azurerm::parse_resource_id(tolist(var.managed_identities.user_assigned_resource_ids)[0]) : null

  # Principal ID used for role assignments owned by this module.
  # User-assigned mode → look up the UAMI's principal_id via data source.
  # System-assigned mode → use the cluster's auto-generated identity.
  identity_principal_id = (
    length(var.managed_identities.user_assigned_resource_ids) > 0
    ? data.azurerm_user_assigned_identity.k8s[0].principal_id
    : azurerm_kubernetes_cluster.this.identity[0].principal_id
  )
}