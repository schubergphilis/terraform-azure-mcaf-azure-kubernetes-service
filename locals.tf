locals {
  user_assigned_identity = provider::azurerm::parse_resource_id(var.user_assigned_identity_id)
}