# Network Profile Configuration Tests
# Tests network_profile branches and the conditional route table resources

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

run "azure_cilium_cni_overlay_check" {
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
      network_policy      = "cilium"
      network_data_plane  = "cilium"
      outbound_type       = "loadBalancer"
      dns_service_ip      = "10.0.0.10"
      pod_cidr            = "10.1.0.0/16"
      service_cidr        = "10.0.0.0/16"
      load_balancer_sku   = "standard"
    }
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.network_profile[0].network_plugin == "azure"
    error_message = "network_plugin should be azure"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.network_profile[0].network_plugin_mode == "overlay"
    error_message = "network_plugin_mode should be overlay"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.network_profile[0].network_policy == "cilium"
    error_message = "network_policy should be cilium"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.network_profile[0].network_data_plane == "cilium"
    error_message = "network_data_plane should be cilium"
  }
}

run "load_balancer_skips_route_table" {
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
    condition     = length(azurerm_route_table.this) == 0
    error_message = "route table must not be created when outbound_type is loadBalancer"
  }

  assert {
    condition     = length(azurerm_route.internet) == 0
    error_message = "internet route must not be created when outbound_type is loadBalancer"
  }

  assert {
    condition     = length(azurerm_subnet_route_table_association.subnet_route_table) == 0
    error_message = "subnet/route_table association must not be created when outbound_type is loadBalancer"
  }
}

run "user_defined_routing_creates_route_table" {
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
      outbound_type       = "userDefinedRouting"
      service_cidr        = "10.0.0.0/16"
    }
    route_table = {
      name                   = "aks-rt"
      next_hop_in_ip_address = "10.0.0.4"
    }
  }

  assert {
    condition     = length(azurerm_route_table.this) == 1
    error_message = "route table must be created when outbound_type is userDefinedRouting"
  }

  assert {
    condition     = length(azurerm_route.internet) == 1
    error_message = "internet route must be created when outbound_type is userDefinedRouting"
  }

  assert {
    condition     = length(azurerm_subnet_route_table_association.subnet_route_table) == 1
    error_message = "subnet/route_table association must be created when outbound_type is userDefinedRouting"
  }
}

run "additional_routes_when_udr" {
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
      outbound_type       = "userDefinedRouting"
      service_cidr        = "10.0.0.0/16"
    }
    route_table = {
      name                   = "aks-rt"
      next_hop_in_ip_address = "10.0.0.4"
    }
    additional_routes = {
      route1 = {
        name                   = "route1"
        address_prefix         = "10.10.0.0/16"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.0.0.4"
      }
      route2 = {
        name                   = "route2"
        address_prefix         = "10.20.0.0/16"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.0.0.4"
      }
    }
  }

  assert {
    condition     = length(azurerm_route.additional_routes) == 2
    error_message = "additional routes must be created when outbound_type is userDefinedRouting"
  }
}

# NOTE: azurerm_role_assignment.aks_vnet_rbac uses count = network_plugin_mode == "azure" ? 0 : 1.
# The provider only accepts "overlay" or null for network_plugin_mode, so the "azure" branch is
# unreachable and the role assignment is always created in practice. Likely a module bug — the
# author probably meant to check network_plugin instead of network_plugin_mode.

run "vnet_role_assignment_created_for_overlay" {
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
    condition     = length(azurerm_role_assignment.aks_vnet_rbac) == 1
    error_message = "VNet Network Contributor role assignment is created on overlay (per current module logic)"
  }
}



# ========================================
# network_profile variable validation tests
# ========================================

run "reject_cilium_without_overlay_or_pod_subnet" {
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
      network_plugin_mode = null
      network_policy      = "cilium"
      network_data_plane  = "cilium"
      outbound_type       = "loadBalancer"
      service_cidr        = "10.0.0.0/16"
    }
  }

  expect_failures = [
    var.network_profile,
  ]
}

run "reject_cilium_with_kubenet" {
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
      network_plugin      = "kubenet"
      network_plugin_mode = "overlay"
      network_policy      = "cilium"
      network_data_plane  = "cilium"
      outbound_type       = "loadBalancer"
      service_cidr        = "10.0.0.0/16"
    }
  }

  expect_failures = [
    var.network_profile,
  ]
}

run "reject_load_balancer_profile_with_basic_sku" {
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
      load_balancer_sku   = "basic"
      load_balancer_profile = {
        managed_outbound_ip_count = 2
      }
    }
  }

  expect_failures = [
    var.network_profile,
  ]
}

# ========================================
# api_server_access_profile.authorized_ip_ranges — public IPs only
# ========================================

run "reject_authorized_ip_ranges_rfc1918_10" {
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
    api_server_access_profile = {
      authorized_ip_ranges = ["10.0.0.0/24"]
    }
  }

  expect_failures = [
    var.api_server_access_profile,
  ]
}

run "reject_authorized_ip_ranges_rfc1918_172" {
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
    api_server_access_profile = {
      authorized_ip_ranges = ["172.16.0.0/16"]
    }
  }

  expect_failures = [
    var.api_server_access_profile,
  ]
}

run "reject_authorized_ip_ranges_rfc1918_192" {
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
    api_server_access_profile = {
      authorized_ip_ranges = ["192.168.1.0/24"]
    }
  }

  expect_failures = [
    var.api_server_access_profile,
  ]
}

run "reject_authorized_ip_ranges_mixed_public_and_private" {
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
    api_server_access_profile = {
      authorized_ip_ranges = ["203.0.113.5/32", "10.0.0.0/24"]
    }
  }

  expect_failures = [
    var.api_server_access_profile,
  ]
}

run "accept_authorized_ip_ranges_public" {
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
    api_server_access_profile = {
      authorized_ip_ranges = ["203.0.113.5/32", "198.51.100.0/24"]
    }
  }

  assert {
    condition     = length(azurerm_kubernetes_cluster.this.api_server_access_profile) == 1
    error_message = "api_server_access_profile block must be created when var is set"
  }
}

run "accept_null_api_server_access_profile" {
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
    # api_server_access_profile defaults to null
  }
}

