# Shared test fixture values for AKS module tests
# This module provides standard test values that can be reused across test files

terraform {
  required_version = ">= 1.9"
}

locals {
  test_resource_group_name      = "rg-test"
  test_location                 = "westeurope"
  test_kubernetes_cluster_name  = "aks-test"
  test_dns_prefix               = "akstest"
  test_node_resource_group_name = "rg-test-nodes"

  test_vnet_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
  test_node_subnet         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
  test_pod_subnet          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/pod-subnet"
  test_uami_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-test"
  test_private_dns_zone_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/privateDnsZones/privatelink.westeurope.azmk8s.io"
}

output "test_resource_group_name" {
  value = local.test_resource_group_name
}

output "test_location" {
  value = local.test_location
}

output "test_kubernetes_cluster_name" {
  value = local.test_kubernetes_cluster_name
}

output "test_dns_prefix" {
  value = local.test_dns_prefix
}

output "test_node_resource_group_name" {
  value = local.test_node_resource_group_name
}

output "test_vnet_id" {
  value = local.test_vnet_id
}

output "test_node_subnet" {
  value = local.test_node_subnet
}

output "test_pod_subnet" {
  value = local.test_pod_subnet
}

output "test_uami_id" {
  value = local.test_uami_id
}

output "test_private_dns_zone_id" {
  value = local.test_private_dns_zone_id
}
