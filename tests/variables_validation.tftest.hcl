# Variable Validation Tests
# Tests all variable validation rules defined in variables.tf

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

# ========================================
# sku_tier validation tests
# ========================================

run "reject_invalid_sku_tier" {
  command = plan

  variables {
    resource_group_name      = "rg-test"
    location                 = "westeurope"
    kubernetes_cluster_name  = "aks-test"
    dns_prefix               = "akstest"
    node_resource_group_name = "rg-test-nodes"
    node_subnet              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    sku_tier                 = "INVALID"
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

  expect_failures = [
    var.sku_tier,
  ]
}

run "accept_sku_tier_free" {
  command = plan

  variables {
    resource_group_name      = "rg-test"
    location                 = "westeurope"
    kubernetes_cluster_name  = "aks-test"
    dns_prefix               = "akstest"
    node_resource_group_name = "rg-test-nodes"
    node_subnet              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    sku_tier                 = "Free"
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
}

run "accept_sku_tier_premium" {
  command = plan

  variables {
    resource_group_name      = "rg-test"
    location                 = "westeurope"
    kubernetes_cluster_name  = "aks-test"
    dns_prefix               = "akstest"
    node_resource_group_name = "rg-test-nodes"
    node_subnet              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    sku_tier                 = "Premium"
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
}

# ========================================
# support_plan validation tests
# ========================================

run "reject_invalid_support_plan" {
  command = plan

  variables {
    resource_group_name      = "rg-test"
    location                 = "westeurope"
    kubernetes_cluster_name  = "aks-test"
    dns_prefix               = "akstest"
    node_resource_group_name = "rg-test-nodes"
    node_subnet              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    support_plan             = "INVALID"
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

  expect_failures = [
    var.support_plan,
  ]
}

run "accept_long_term_support_plan" {
  command = plan

  variables {
    resource_group_name      = "rg-test"
    location                 = "westeurope"
    kubernetes_cluster_name  = "aks-test"
    dns_prefix               = "akstest"
    node_resource_group_name = "rg-test-nodes"
    node_subnet              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    support_plan             = "AKSLongTermSupport"
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
}

# ========================================
# cost_analysis_enabled validation tests
# ========================================

run "reject_cost_analysis_with_free_tier" {
  command = plan

  variables {
    resource_group_name      = "rg-test"
    location                 = "westeurope"
    kubernetes_cluster_name  = "aks-test"
    dns_prefix               = "akstest"
    node_resource_group_name = "rg-test-nodes"
    node_subnet              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    sku_tier                 = "Free"
    cost_analysis_enabled    = true
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

  expect_failures = [
    var.cost_analysis_enabled,
  ]
}

run "accept_cost_analysis_with_standard_tier" {
  command = plan

  variables {
    resource_group_name      = "rg-test"
    location                 = "westeurope"
    kubernetes_cluster_name  = "aks-test"
    dns_prefix               = "akstest"
    node_resource_group_name = "rg-test-nodes"
    node_subnet              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    sku_tier                 = "Standard"
    cost_analysis_enabled    = true
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
}

# ========================================
# image_cleaner_interval_hours validation tests
# ========================================

run "reject_image_cleaner_interval_below_24" {
  command = plan

  variables {
    resource_group_name          = "rg-test"
    location                     = "westeurope"
    kubernetes_cluster_name      = "aks-test"
    dns_prefix                   = "akstest"
    node_resource_group_name     = "rg-test-nodes"
    node_subnet                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    image_cleaner_interval_hours = 12
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

  expect_failures = [
    var.image_cleaner_interval_hours,
  ]
}

run "reject_image_cleaner_interval_above_2160" {
  command = plan

  variables {
    resource_group_name          = "rg-test"
    location                     = "westeurope"
    kubernetes_cluster_name      = "aks-test"
    dns_prefix                   = "akstest"
    node_resource_group_name     = "rg-test-nodes"
    node_subnet                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    image_cleaner_interval_hours = 3000
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

  expect_failures = [
    var.image_cleaner_interval_hours,
  ]
}

run "accept_image_cleaner_interval_in_range" {
  command = plan

  variables {
    resource_group_name          = "rg-test"
    location                     = "westeurope"
    kubernetes_cluster_name      = "aks-test"
    dns_prefix                   = "akstest"
    node_resource_group_name     = "rg-test-nodes"
    node_subnet                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    image_cleaner_interval_hours = 168
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
}

# ========================================
# automatic_upgrade_channel validation tests
# ========================================

run "reject_invalid_automatic_upgrade_channel" {
  command = plan

  variables {
    resource_group_name       = "rg-test"
    location                  = "westeurope"
    kubernetes_cluster_name   = "aks-test"
    dns_prefix                = "akstest"
    node_resource_group_name  = "rg-test-nodes"
    node_subnet               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    automatic_upgrade_channel = "weekly"
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

  expect_failures = [
    var.automatic_upgrade_channel,
  ]
}

run "accept_automatic_upgrade_channel_stable" {
  command = plan

  variables {
    resource_group_name       = "rg-test"
    location                  = "westeurope"
    kubernetes_cluster_name   = "aks-test"
    dns_prefix                = "akstest"
    node_resource_group_name  = "rg-test-nodes"
    node_subnet               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    automatic_upgrade_channel = "stable"
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
}

# ========================================
# node_os_upgrade_channel validation tests
# ========================================

run "reject_invalid_node_os_upgrade_channel" {
  command = plan

  variables {
    resource_group_name      = "rg-test"
    location                 = "westeurope"
    kubernetes_cluster_name  = "aks-test"
    dns_prefix               = "akstest"
    node_resource_group_name = "rg-test-nodes"
    node_subnet              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    node_os_upgrade_channel  = "weekly"
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

  expect_failures = [
    var.node_os_upgrade_channel,
  ]
}

run "accept_node_os_upgrade_channel_security_patch" {
  command = plan

  variables {
    resource_group_name      = "rg-test"
    location                 = "westeurope"
    kubernetes_cluster_name  = "aks-test"
    dns_prefix               = "akstest"
    node_resource_group_name = "rg-test-nodes"
    node_subnet              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    node_os_upgrade_channel  = "SecurityPatch"
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
}

# ========================================
# system_node_pool.temporary_name_for_rotation validation tests
# ========================================

run "reject_system_node_pool_temp_name_uppercase" {
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
      temporary_name_for_rotation = "RotateNow"
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

  expect_failures = [
    var.system_node_pool,
  ]
}

run "reject_system_node_pool_temp_name_too_long" {
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
      temporary_name_for_rotation = "rotateforaverylong"
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

  expect_failures = [
    var.system_node_pool,
  ]
}

run "accept_system_node_pool_temp_name_valid" {
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
      temporary_name_for_rotation = "rtsystem"
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
}

# ========================================
# diagnostic_settings validation tests
# ========================================

run "reject_diagnostic_settings_no_destination" {
  command = plan

  variables {
    resource_group_name      = "rg-test"
    location                 = "westeurope"
    kubernetes_cluster_name  = "aks-test"
    dns_prefix               = "akstest"
    node_resource_group_name = "rg-test-nodes"
    node_subnet              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    diagnostic_settings = {
      one = {
        log_analytics_destination_type = "Dedicated"
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

  expect_failures = [
    var.diagnostic_settings,
  ]
}

run "reject_diagnostic_settings_invalid_destination_type" {
  command = plan

  variables {
    resource_group_name      = "rg-test"
    location                 = "westeurope"
    kubernetes_cluster_name  = "aks-test"
    dns_prefix               = "akstest"
    node_resource_group_name = "rg-test-nodes"
    node_subnet              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    diagnostic_settings = {
      one = {
        log_analytics_destination_type = "Other"
        workspace_resource_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.OperationalInsights/workspaces/law-test"
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

  expect_failures = [
    var.diagnostic_settings,
  ]
}

run "accept_diagnostic_settings_with_workspace" {
  command = plan

  variables {
    resource_group_name      = "rg-test"
    location                 = "westeurope"
    kubernetes_cluster_name  = "aks-test"
    dns_prefix               = "akstest"
    node_resource_group_name = "rg-test-nodes"
    node_subnet              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    diagnostic_settings = {
      one = {
        log_analytics_destination_type = "Dedicated"
        workspace_resource_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.OperationalInsights/workspaces/law-test"
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
}
