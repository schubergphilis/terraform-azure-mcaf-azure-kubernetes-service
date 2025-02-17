data "azurerm_user_assigned_identity" "k8s" {
  name                = var.user_assigned_identity_name
  resource_group_name = var.resource_group_name
}