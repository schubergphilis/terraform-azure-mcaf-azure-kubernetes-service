data "azurerm_user_assigned_identity" "k8s" {
  name                = local.user_assigned_identity.resource_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subscription" "current" {}