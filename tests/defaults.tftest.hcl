# Default Values and Plan-Level Tests
# Tests that default values produce the expected plan configuration

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

run "verify_default_values" {
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

  # Verify default kubernetes_version
  assert {
    condition     = var.kubernetes_version == "1.31.5"
    error_message = "Default kubernetes_version should be 1.31.5"
  }

  # Verify default sku_tier
  assert {
    condition     = azurerm_kubernetes_cluster.this.sku_tier == "Standard"
    error_message = "Default sku_tier should be Standard"
  }

  # Verify default support_plan
  assert {
    condition     = azurerm_kubernetes_cluster.this.support_plan == "KubernetesOfficial"
    error_message = "Default support_plan should be KubernetesOfficial"
  }

  # Verify default local_account_disabled
  assert {
    condition     = azurerm_kubernetes_cluster.this.local_account_disabled == true
    error_message = "Default local_account_disabled should be true"
  }

  # Verify default workload_identity_enabled
  assert {
    condition     = azurerm_kubernetes_cluster.this.workload_identity_enabled == false
    error_message = "Default workload_identity_enabled should be false"
  }

  # Verify default oidc_issuer_enabled
  assert {
    condition     = azurerm_kubernetes_cluster.this.oidc_issuer_enabled == false
    error_message = "Default oidc_issuer_enabled should be false"
  }

  # Verify default azure_policy_enabled
  assert {
    condition     = azurerm_kubernetes_cluster.this.azure_policy_enabled == true
    error_message = "Default azure_policy_enabled should be true"
  }

  # Verify default run_command_enabled
  assert {
    condition     = azurerm_kubernetes_cluster.this.run_command_enabled == false
    error_message = "Default run_command_enabled should be false"
  }

  # Verify default private_cluster_enabled
  assert {
    condition     = azurerm_kubernetes_cluster.this.private_cluster_enabled == false
    error_message = "Default private_cluster_enabled should be false"
  }

  # Verify default image_cleaner_enabled
  assert {
    condition     = azurerm_kubernetes_cluster.this.image_cleaner_enabled == false
    error_message = "Default image_cleaner_enabled should be false"
  }

  # Verify cluster name
  assert {
    condition     = azurerm_kubernetes_cluster.this.name == "aks-test"
    error_message = "Cluster name should match input"
  }

  # Verify dns_prefix
  assert {
    condition     = azurerm_kubernetes_cluster.this.dns_prefix == "akstest"
    error_message = "dns_prefix should match input"
  }

  # Verify node_resource_group
  assert {
    condition     = azurerm_kubernetes_cluster.this.node_resource_group == "rg-test-nodes"
    error_message = "node_resource_group should match input"
  }
}

run "verify_workload_identity_enabled" {
  command = plan

  variables {
    resource_group_name       = "rg-test"
    location                  = "westeurope"
    kubernetes_cluster_name   = "aks-test"
    dns_prefix                = "akstest"
    node_resource_group_name  = "rg-test-nodes"
    node_subnet               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    workload_identity_enabled = true
    oidc_issuer_enabled       = true
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
    condition     = azurerm_kubernetes_cluster.this.workload_identity_enabled == true
    error_message = "workload_identity_enabled should be true when set"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.oidc_issuer_enabled == true
    error_message = "oidc_issuer_enabled should be true when workload identity is to be enabled"
  }
}

run "verify_custom_kubernetes_version" {
  command = plan

  variables {
    resource_group_name      = "rg-test"
    location                 = "westeurope"
    kubernetes_cluster_name  = "aks-test"
    dns_prefix               = "akstest"
    node_resource_group_name = "rg-test-nodes"
    node_subnet              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    kubernetes_version       = "1.33.8"
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
    condition     = azurerm_kubernetes_cluster.this.kubernetes_version == "1.33.8"
    error_message = "kubernetes_version should be configurable"
  }
}

run "verify_sku_tier_free" {
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

  assert {
    condition     = azurerm_kubernetes_cluster.this.sku_tier == "Free"
    error_message = "sku_tier should be Free when set"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.cost_analysis_enabled == false
    error_message = "cost_analysis_enabled must be coerced to false on Free tier"
  }
}

run "verify_tags_passthrough" {
  command = plan

  variables {
    resource_group_name      = "rg-test"
    location                 = "westeurope"
    kubernetes_cluster_name  = "aks-test"
    dns_prefix               = "akstest"
    node_resource_group_name = "rg-test-nodes"
    node_subnet              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/aks-subnet"
    vnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    tags = {
      environment = "test"
      owner       = "platform"
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
    condition     = azurerm_kubernetes_cluster.this.tags["environment"] == "test"
    error_message = "tags should propagate to the cluster"
  }
}
