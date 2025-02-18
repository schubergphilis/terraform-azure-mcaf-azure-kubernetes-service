locals {
  user_assigned_identity = provider::azurerm::parse_resource_id(var.control_plane_user_assigned_identity_id)
}