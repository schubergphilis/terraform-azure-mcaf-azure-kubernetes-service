data "azurerm_user_assigned_identity" "k8s" {
  count               = length(var.managed_identities.user_assigned_resource_ids) > 0 ? 1 : 0
  name                = local.user_assigned_identity.resource_name
  resource_group_name = var.resource_group_name
}

