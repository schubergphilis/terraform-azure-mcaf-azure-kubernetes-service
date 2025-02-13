locals {
  vnet_id = provider::azurerm::parse_resource_id(var.node_subnet)
}