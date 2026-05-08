# Managed Identity Configuration Tests
# Tests the managed_identities branches: system, user, both

mock_provider "azurerm" {
  override_data {
    target = data.azurerm_user_assigned_identity.k8s
    values = {
      principal_id = "00000000-0000-0000-0000-000000000000"
      client_id    = "11111111-1111-1111-1111-111111111111"
      tenant_id    = "22222222-2222-2222-2222-222222222222"
    }
  }
}

run "user_assigned_only" {
  command = plan

  variables {
    resource_group_name      = "rg-test"
    location                 = "westeurope"
    kubernetes_cluster_name  = "aks-test"
    dns_prefix               = "akstest"
    node_resource_group_name = "rg-test-nodes"
    node_subnet              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    managed_identities = {
      user_assigned_resource_ids = [
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-test"
      ]
    }
    network_profile = {
      network_plugin      = "azure"
      network_plugin_mode = "overlay"
      outbound_type       = "loadBalancer"
      service_cidr        = "10.0.0.0/16"
    }
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.identity[0].type == "UserAssigned"
    error_message = "identity type should be UserAssigned when only user_assigned_resource_ids is set"
  }
}

# ========================================
# managed_identities variable validation tests
# ========================================

run "reject_system_assigned_with_private_cluster" {
  command = plan

  variables {
    resource_group_name      = "rg-test"
    location                 = "westeurope"
    kubernetes_cluster_name  = "aks-test"
    dns_prefix               = "akstest"
    node_resource_group_name = "rg-test-nodes"
    node_subnet              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    private_cluster_enabled  = true
    private_dns_zone_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/privateDnsZones/privatelink.westeurope.azmk8s.io"
    managed_identities = {
      system_assigned            = true
      user_assigned_resource_ids = []
    }
    network_profile = {
      network_plugin      = "azure"
      network_plugin_mode = "overlay"
      outbound_type       = "loadBalancer"
      service_cidr        = "10.0.0.0/16"
    }
  }

  expect_failures = [
    var.managed_identities,
  ]
}

run "accept_user_assigned_with_private_cluster" {
  command = plan

  variables {
    resource_group_name      = "rg-test"
    location                 = "westeurope"
    kubernetes_cluster_name  = "aks-test"
    dns_prefix               = "akstest"
    node_resource_group_name = "rg-test-nodes"
    node_subnet              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    private_cluster_enabled  = true
    private_dns_zone_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/privateDnsZones/privatelink.westeurope.azmk8s.io"
    managed_identities = {
      user_assigned_resource_ids = [
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-test"
      ]
    }
    network_profile = {
      network_plugin      = "azure"
      network_plugin_mode = "overlay"
      outbound_type       = "loadBalancer"
      service_cidr        = "10.0.0.0/16"
    }
  }

  assert {
    condition     = length(azurerm_role_assignment.aks_dns) == 1
    error_message = "Private DNS Zone Contributor role assignment must be created on private clusters"
  }
}

run "network_contributor_scoped_to_subnet_not_vnet" {
  command = plan

  variables {
    resource_group_name      = "rg-test"
    location                 = "westeurope"
    kubernetes_cluster_name  = "aks-test"
    dns_prefix               = "akstest"
    node_resource_group_name = "rg-test-nodes"
    node_subnet              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    managed_identities = {
      user_assigned_resource_ids = [
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-test"
      ]
    }
    network_profile = {
      network_plugin      = "azure"
      network_plugin_mode = "overlay"
      outbound_type       = "loadBalancer"
      service_cidr        = "10.0.0.0/16"
    }
  }

  assert {
    condition     = length(azurerm_role_assignment.aks_subnet_rbac) == 1
    error_message = "Network Contributor role assignment must exist scoped to the node subnet"
  }

  assert {
    condition     = azurerm_role_assignment.aks_subnet_rbac[0].scope == var.node_subnet
    error_message = "Network Contributor role assignment must be scoped to the node subnet, not the VNet"
  }

  assert {
    condition     = azurerm_role_assignment.aks_subnet_rbac[0].role_definition_name == "Network Contributor"
    error_message = "subnet-level role assignment must be Network Contributor"
  }
  assert {
    condition     = length(azurerm_role_assignment.aks_vnet_rbac) != 1
    error_message = "Network Contributor role assignment must exist scoped to the node subnet, not at vnet-level"
  }

  assert {
    condition     = azurerm_role_assignment.aks_vnet_rbac[0].scope == var.node_subnet
    error_message = "Network Contributor role assignment must be scoped to the node subnet, not the VNet"
  }

  assert {
    condition     = azurerm_role_assignment.aks_vnet_rbac[0].role_definition_name != "Network Contributor"
    error_message = "vnet-level role assignment must be Network Contributor"
  }
}
