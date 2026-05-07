# Node Pool Configuration Tests
# Tests system_node_pool defaults and user_node_pool iteration

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

run "default_system_node_pool" {
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
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].name == "system"
    error_message = "default node pool name should default to 'system'"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].vm_size == "Standard_B2s"
    error_message = "default node pool vm_size should default to Standard_B2s"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].auto_scaling_enabled == false
    error_message = "default node pool auto_scaling should default to false"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].only_critical_addons_enabled == true
    error_message = "default node pool should be tainted for critical addons by default"
  }

  assert {
    condition     = length(azurerm_kubernetes_cluster.this.default_node_pool[0].zones) == 3
    error_message = "default node pool should span 3 availability zones by default"
  }
}

run "system_node_pool_autoscale_enabled" {
  command = plan

  variables {
    resource_group_name      = "rg-test"
    location                 = "westeurope"
    kubernetes_cluster_name  = "aks-test"
    dns_prefix               = "akstest"
    node_resource_group_name = "rg-test-nodes"
    node_subnet              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    system_node_pool = {
      auto_scaling_enabled = true
      min_count            = 2
      max_count            = 5
      vm_size              = "Standard_D2s_v5"
      os_sku               = "AzureLinux"
    }
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
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].auto_scaling_enabled == true
    error_message = "auto_scaling_enabled should be true when set"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].min_count == 2
    error_message = "min_count should be set when auto-scaling is enabled"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].max_count == 5
    error_message = "max_count should be set when auto-scaling is enabled"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].vm_size == "Standard_D2s_v5"
    error_message = "vm_size should be configurable"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].os_sku == "AzureLinux"
    error_message = "os_sku should be configurable"
  }
}

run "system_node_pool_autoscale_disabled_clears_min_max" {
  command = plan

  variables {
    resource_group_name      = "rg-test"
    location                 = "westeurope"
    kubernetes_cluster_name  = "aks-test"
    dns_prefix               = "akstest"
    node_resource_group_name = "rg-test-nodes"
    node_subnet              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    system_node_pool = {
      auto_scaling_enabled = false
      min_count            = 2
      max_count            = 5
    }
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
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].min_count == null
    error_message = "min_count must be null when auto_scaling_enabled is false"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].max_count == null
    error_message = "max_count must be null when auto_scaling_enabled is false"
  }
}

run "no_user_node_pools_by_default" {
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
    condition     = length(azurerm_kubernetes_cluster_node_pool.this) == 0
    error_message = "no user node pools should be created by default"
  }
}

run "user_node_pools_iteration" {
  command = plan

  variables {
    resource_group_name      = "rg-test"
    location                 = "westeurope"
    kubernetes_cluster_name  = "aks-test"
    dns_prefix               = "akstest"
    node_resource_group_name = "rg-test-nodes"
    node_subnet              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    user_node_pool = {
      "general" = {
        name       = "general"
        vm_size    = "Standard_D2s_v5"
        node_count = 2
      }
      "memory" = {
        name       = "memory"
        vm_size    = "Standard_E2s_v5"
        node_count = 1
      }
    }
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
    condition     = length(azurerm_kubernetes_cluster_node_pool.this) == 2
    error_message = "two user node pools must be created"
  }

  assert {
    condition     = azurerm_kubernetes_cluster_node_pool.this["general"].vm_size == "Standard_D2s_v5"
    error_message = "user_node_pool 'general' vm_size mismatch"
  }

  assert {
    condition     = azurerm_kubernetes_cluster_node_pool.this["memory"].vm_size == "Standard_E2s_v5"
    error_message = "user_node_pool 'memory' vm_size mismatch"
  }
}
