resource "azurerm_kubernetes_cluster" "this" {
  name                         = var.kubernetes_cluster_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  kubernetes_version           = var.kubernetes_version
  dns_prefix                   = var.dns_prefix
  cost_analysis_enabled        = var.sku_tier == "Free" ? false : var.cost_analysis_enabled
  private_cluster_enabled      = var.private_cluster_enabled
  private_dns_zone_id          = var.private_cluster_enabled == true ? var.private_dns_zone_id : null
  automatic_upgrade_channel    = var.automatic_upgrade_channel
  node_os_upgrade_channel      = var.node_os_upgrade_channel
  image_cleaner_enabled        = var.image_cleaner_enabled
  image_cleaner_interval_hours = var.image_cleaner_interval_hours
  sku_tier                     = var.sku_tier
  workload_identity_enabled    = var.workload_identity_enabled
  oidc_issuer_enabled          = var.oidc_issuer_enabled
  azure_policy_enabled         = var.azure_policy_enabled
  disk_encryption_set_id       = var.disk_encryption_set_id
  local_account_disabled       = var.local_account_disabled
  run_command_enabled          = var.run_command_enabled
  support_plan                 = var.support_plan
  tags                         = var.tags
  node_resource_group          = var.node_resource_group_name

  default_node_pool {
    name           = var.system_node_pool.name
    vm_size        = var.system_node_pool.vm_size
    vnet_subnet_id = try(var.system_node_pool.node_subnet_id, var.node_subnet, null)
    pod_subnet_id  = try(var.system_node_pool.pod_subnet_id, var.pod_subnet, null)

    zones                        = var.system_node_pool.availability_zones
    node_labels                  = var.system_node_pool.node_labels
    only_critical_addons_enabled = var.system_node_pool.only_critical_addons_enabled
    auto_scaling_enabled         = var.system_node_pool.auto_scaling_enabled
    host_encryption_enabled      = var.system_node_pool.host_encryption_enabled
    node_public_ip_enabled       = var.system_node_pool.enable_node_public_ip
    max_pods                     = var.system_node_pool.max_pods
    max_count                    = var.system_node_pool.auto_scaling_enabled == true ? var.system_node_pool.max_count : null
    min_count                    = var.system_node_pool.auto_scaling_enabled == true ? var.system_node_pool.min_count : null
    node_count                   = var.system_node_pool.node_count
    os_disk_type                 = var.system_node_pool.os_disk_type
    os_disk_size_gb              = var.system_node_pool.os_disk_size_gb
    os_sku                       = var.system_node_pool.os_sku
    ultra_ssd_enabled            = var.system_node_pool.ultra_ssd_enabled
    temporary_name_for_rotation  = var.system_node_pool.temporary_name_for_rotation

    upgrade_settings {
      max_surge                     = var.system_node_pool.upgrade_settings.max_surge
      drain_timeout_in_minutes      = var.system_node_pool.upgrade_settings.drain_timeout_in_minutes
      node_soak_duration_in_minutes = var.system_node_pool.upgrade_settings.node_soak_duration_in_minutes
    }

    tags = merge(
      try(var.tags),
      try(var.system_node_pool.tags),
      tomap({
        "Resource Type" = "Kubernetes System Node"
      })
    )
  }

  dynamic "kubelet_identity" {
    for_each = var.kubelet_identity != null ? [var.kubelet_identity] : []

    content {
      client_id                 = kubelet_identity.value.client_id 
      object_id                 = kubelet_identity.value.object_id 
      user_assigned_identity_id = kubelet_identity.value.user_assigned_identity_id 
    }
  }

  dynamic "linux_profile" {
    for_each = try(var.linux_profile, null) == null ? [] : [1]
    content {
      admin_username = try(var.linux_profile.admin_username, null)
      dynamic "ssh_key" {
        for_each = try(var.linux_profile.ssh_key, null) == null ? [] : [1]
        content {
          key_data = try(var.linux_profile.ssh_key.key_data, null)
        }
      }
    }
  }

  dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned

    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }
  
  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []
    
    content {
      dynamic "allowed" {
        for_each = var.maintenance_window.allowed != null ? [var.maintenance_window.allowed] : []

        content {
          day    = maintenance_window.value.allowed.day
          hours  = maintenance_window.value.allowed.hours
        }
      }
      
      dynamic "not_allowed" {
        for_each = var.maintenance_window.not_allowed != null ? [var.maintenance_window.not_allowed] : []
      
        content {
          end    = maintenance_window.value.not_allowed.end
          start  = maintenance_window.value.not_allowed.start
        }
      }
    }
  }

  dynamic "maintenance_window_auto_upgrade" {
    for_each = var.maintenance_window_auto_upgrade != null ? [var.maintenance_window_auto_upgrade] : []
    
    content {
      frequency    = maintenance_window_auto_upgrade.value.frequency
      interval     = maintenance_window_auto_upgrade.value.interval
      duration     = maintenance_window_auto_upgrade.value.duration
      day_of_week  = maintenance_window_auto_upgrade.value.day_of_week
      week_index   = maintenance_window_auto_upgrade.value.week_index
      start_time   = maintenance_window_auto_upgrade.value.start_time
      utc_offset   = maintenance_window_auto_upgrade.value.utc_offset
      start_date   = maintenance_window_auto_upgrade.value.start_date
      
      dynamic "not_allowed" {
        for_each = var.maintenance_window_auto_upgrade.not_allowed != null ? [var.maintenance_window_auto_upgrade.not_allowed] : []
      
        content {
          end    = maintenance_window_auto_upgrade.value.not_allowed.end
          start  = maintenance_window_auto_upgrade.value.not_allowed.start
        }
      }
    }
  }
  
  dynamic "maintenance_window_node_os" {
    for_each = var.maintenance_window_node_os != null ? [var.maintenance_window_node_os] : []
    
    content {
      frequency    = maintenance_window_node_os.value.frequency
      interval     = maintenance_window_node_os.value.interval
      duration     = maintenance_window_node_os.value.duration
      day_of_week  = maintenance_window_node_os.value.day_of_week
      week_index   = maintenance_window_node_os.value.week_index
      start_time   = maintenance_window_node_os.value.start_time
      utc_offset   = maintenance_window_node_os.value.utc_offset
      start_date   = maintenance_window_node_os.value.start_date
    }
  }
  
  network_profile {
    network_plugin      = var.network_profile.network_plugin
    dns_service_ip      = var.network_profile.dns_service_ip
    ip_versions         = var.network_profile.ip_versions
    load_balancer_sku   = var.network_profile.load_balancer_sku
    network_data_plane  = var.network_profile.network_data_plane
    network_mode        = var.network_profile.network_mode
    network_plugin_mode = var.network_profile.network_plugin_mode
    network_policy      = var.network_profile.network_policy
    outbound_type       = var.network_profile.outbound_type
    pod_cidr            = var.network_profile.pod_cidr
    pod_cidrs           = var.network_profile.pod_cidrs
    service_cidr        = var.network_profile.service_cidr
    service_cidrs       = var.network_profile.service_cidrs

    dynamic "load_balancer_profile" {
      for_each = var.network_profile.load_balancer_profile != null ? [var.network_profile.load_balancer_profile] : []

      content {
        idle_timeout_in_minutes     = var.network_profile.load_balancer_profile.idle_timeout_in_minutes
        managed_outbound_ip_count   = var.network_profile.load_balancer_profile.managed_outbound_ip_count
        managed_outbound_ipv6_count = var.network_profile.load_balancer_profile.managed_outbound_ipv6_count
        outbound_ip_address_ids     = var.network_profile.load_balancer_profile.outbound_ip_address_ids
        outbound_ip_prefix_ids      = var.network_profile.load_balancer_profile.outbound_ip_prefix_ids
        outbound_ports_allocated    = var.network_profile.load_balancer_profile.outbound_ports_allocated
      }
    }
    dynamic "nat_gateway_profile" {
      for_each = var.network_profile.nat_gateway_profile != null ? [var.network_profile.nat_gateway_profile] : []

      content {
        idle_timeout_in_minutes   = var.network_profile.nat_gateway_profile.idle_timeout_in_minutes
        managed_outbound_ip_count = var.network_profile.nat_gateway_profile.managed_outbound_ip_count
      }
    }
  }

  dynamic "api_server_access_profile" {
    for_each = var.api_server_access_profile != null ? [var.api_server_access_profile] : []

    content {
      authorized_ip_ranges = api_server_access_profile.value.authorized_ip_ranges
    }
  }

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.azure_active_directory_role_based_access_control != null ? [var.azure_active_directory_role_based_access_control] : []

    content {
      admin_group_object_ids = azure_active_directory_role_based_access_control.value.admin_group_object_ids
      azure_rbac_enabled     = azure_active_directory_role_based_access_control.value.azure_rbac_enabled
      tenant_id              = azure_active_directory_role_based_access_control.value.tenant_id
    }
  }

  dynamic "workload_autoscaler_profile" {
    for_each = var.workload_autoscaler_profile != null ? [var.workload_autoscaler_profile] : []

    content {
      keda_enabled                    = workload_autoscaler_profile.value.keda_enabled
      vertical_pod_autoscaler_enabled = workload_autoscaler_profile.value.vertical_pod_autoscaler_enabled
    }
  }

  dynamic "microsoft_defender" {
    for_each = var.defender_log_analytics_workspace_id != null ? [var.defender_log_analytics_workspace_id] : []

    content {
      log_analytics_workspace_id = var.defender_log_analytics_workspace_id
    }
  }

  lifecycle {
    ignore_changes = [
      kubernetes_version,
      microsoft_defender
    ]

    precondition {
      condition     = var.network_profile.network_data_plane != "cilium" || (var.network_profile.network_plugin_mode == "overlay" || var.system_node_pool.pod_subnet_id != null)
      error_message = "When network_data_plane is set to cilium, one of either network_plugin_mode = 'overlay' or pod_subnet_id must be specified."
    }

    precondition {
      condition     = var.private_cluster_enabled == false || var.api_server_access_profile == null
      error_message = "api_server_access_profile can only be used when private_cluster_enabled is set to false."
    }
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = var.user_node_pool == null ? {} : var.user_node_pool

  kubernetes_cluster_id       = azurerm_kubernetes_cluster.this.id
  name                        = each.value.name
  vm_size                     = each.value.vm_size
  mode                        = try(each.value.mode, "User")
  node_labels                 = each.value.node_labels
  node_taints                 = each.value.node_taints
  zones                       = each.value.availability_zones
  vnet_subnet_id              = try(each.value.node_subnet_id, var.node_subnet)
  pod_subnet_id               = try(each.value.pod_subnet_id, var.pod_subnet)
  auto_scaling_enabled        = each.value.auto_scaling_enabled
  host_encryption_enabled     = each.value.host_encryption_enabled
  node_public_ip_enabled      = each.value.node_public_ip_enabled
  max_pods                    = each.value.max_pods
  max_count                   = var.system_node_pool.auto_scaling_enabled == true ? var.system_node_pool.max_count : null
  min_count                   = var.system_node_pool.auto_scaling_enabled == true ? var.system_node_pool.min_count : null
  node_count                  = each.value.node_count
  os_disk_size_gb             = each.value.os_disk_size_gb
  os_disk_type                = each.value.os_disk_type
  ultra_ssd_enabled           = each.value.ultra_ssd_enabled
  os_type                     = each.value.os_type
  os_sku                      = each.value.os_sku
  temporary_name_for_rotation = each.value.temporary_name_for_rotation

  dynamic "upgrade_settings" {
    for_each = each.value.upgrade_settings != null ? [each.value.upgrade_settings] : []

    content {
      max_surge                     = upgrade_settings.value.max_surge
      drain_timeout_in_minutes      = upgrade_settings.value.node_soak_duration_in_minutes
      node_soak_duration_in_minutes = upgrade_settings.value.node_soak_duration_in_minutes
    }
  }

  lifecycle {
    precondition {
      condition     = var.network_profile.network_plugin_mode != "overlay" || !can(regex("^Standard_DC[0-9]+s?_v2$", var.user_node_pool.vm_size))
      error_message = "With with Azure CNI Overlay you can't use DCsv2-series virtual machines in node pools. "
    }
  }

  tags = merge(
    try(var.tags),
    try(each.value.tags),
    tomap({
      "Resource Type" = "Kubernetes User Node"
    })
  )
}

resource "azurerm_route_table" "this" {
  count = var.network_profile.outbound_type == "userDefinedRouting" ? 1 : 0

  name                          = var.route_table.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tags                          = var.tags
  bgp_route_propagation_enabled = var.route_table.bgp_route_propagation_enabled
}

resource "azurerm_route" "internet" {
  count = var.network_profile.outbound_type == "userDefinedRouting" ? 1 : 0

  name                   = "internet"
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.this[0].name
  address_prefix         = var.route_table.address_prefix
  next_hop_type          = var.route_table.next_hop_type
  next_hop_in_ip_address = var.route_table.next_hop_in_ip_address

  lifecycle {
    precondition {
      # This route should only be created if the next_hop_in_ip_address is set
      condition     = var.route_table.next_hop_in_ip_address != null
      error_message = "Route must have a next_hop_in_ip_address set, probably your azure firewall ip."
    }
  }
}

resource "azurerm_route" "additional_routes" {
  for_each = var.additional_routes != null ? var.additional_routes : {}

  name                   = each.value.name
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.this[0].name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address

  lifecycle {
    precondition {
      condition     = var.network_profile.outbound_type == "userDefinedRouting"
      error_message = "Additional routes can only be created when outbound_type is set to userDefinedRouting."
    }
  }
}

resource "azurerm_subnet_route_table_association" "subnet_route_table" {
  count = var.network_profile.outbound_type == "userDefinedRouting" ? 1 : 0

  subnet_id      = var.node_subnet
  route_table_id = azurerm_route_table.this[0].id

  depends_on = [azurerm_route_table.this]
}

resource "azurerm_role_assignment" "aks_vnet_rbac" {
  count = var.network_profile.network_plugin_mode == "azure" ? 0 : 1

  scope                = var.vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = data.azurerm_user_assigned_identity.k8s.principal_id

  depends_on = [azurerm_route_table.this]
}

resource "azurerm_role_assignment" "aks_dns" {
  count = var.private_cluster_enabled == true ? 1 : 0

  scope                = var.private_dns_zone_id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = data.azurerm_user_assigned_identity.k8s.principal_id

  lifecycle {
    precondition {
      condition     = var.private_cluster_enabled == true && var.private_dns_zone_id != null
      error_message = "Private DNS Zone Contributor role assignment can only be created when private_cluster_enabled is set to true."
    }
  }
}
