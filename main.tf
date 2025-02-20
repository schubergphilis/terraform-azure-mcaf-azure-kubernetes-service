resource "azurerm_kubernetes_cluster" "this" {
  name                      = var.kubernetes_cluster_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  kubernetes_version        = var.kubernetes_version
  dns_prefix                = var.dns_prefix
  private_cluster_enabled   = var.private_cluster_enabled
  private_dns_zone_id       = var.private_cluster_enabled == true ? var.private_dns_zone : null
  automatic_upgrade_channel = var.automatic_upgrade_channel
  image_cleaner_enabled     = var.image_cleaner_enabled
  sku_tier                  = var.sku_tier
  workload_identity_enabled = var.workload_identity_enabled
  oidc_issuer_enabled       = var.oidc_issuer_enabled
  azure_policy_enabled      = var.azure_policy_enabled
  disk_encryption_set_id    = var.disk_encryption_set_id
  tags                      = var.tags

  node_resource_group = var.node_resource_group_name

  default_node_pool {
    name           = var.system_node_pool.name
    vm_size        = var.system_node_pool.vm_size
    vnet_subnet_id = var.node_subnet
    pod_subnet_id  = try(var.network_plugin == "azure") ? var.pod_subnet : null

    zones                        = var.system_node_pool.availability_zones
    node_labels                  = var.system_node_pool.node_labels
    only_critical_addons_enabled = var.system_node_pool.only_critical_addons_enabled
    auto_scaling_enabled         = var.system_node_pool.enable_auto_scaling
    host_encryption_enabled      = var.system_node_pool.enable_host_encryption
    node_public_ip_enabled       = var.system_node_pool.enable_node_public_ip
    max_pods                     = var.system_node_pool.max_pods
    max_count                    = var.system_node_pool.enable_auto_scaling == true ? var.system_node_pool.max_count : null
    min_count                    = var.system_node_pool.enable_auto_scaling == true ? var.system_node_pool.min_count : null
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
    for_each = var.kubelet_user_assigned_identity_id != null ? [var.kubelet_user_assigned_identity_id] : []

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

  identity {
    type = "UserAssigned"
    # TODO
    identity_ids = tolist([try(var.control_plane_user_assigned_identity_id)])
    # identity_ids = var.aks_managed_identity
  }


  network_profile {
    dns_service_ip      = var.dns_service_ip
    network_plugin      = var.network_plugin
    network_plugin_mode = var.network_plugin_mode
    network_data_plane  = var.network_policy == "cilium" ? "cilium" : "azure" #TODO
    network_policy      = var.network_plugin == "none" ? null : var.network_policy
    outbound_type       = var.outbound_type
    service_cidr        = var.service_cidr
    pod_cidr            = (var.network_plugin == "azure" && var.network_plugin_mode != "overlay") ? null : var.pod_cidr
    load_balancer_sku   = var.load_balancer_sku
  }

  local_account_disabled = true
  # TODO
  azure_active_directory_role_based_access_control {
    admin_group_object_ids = var.aks_administrators
    azure_rbac_enabled     = var.azure_rbac_enabled
  }

  dynamic "workload_autoscaler_profile" {
    for_each = var.workload_autoscaler_profile != null ? [var.workload_autoscaler_profile] : []

    content {
      keda_enabled                    = workload_autoscaler_profile.value.keda_enabled
      vertical_pod_autoscaler_enabled = workload_autoscaler_profile.value.vertical_pod_autoscaler_enabled
    }
  }

  lifecycle {
    ignore_changes = [
      kubernetes_version
    ]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = var.user_node_pool == null ? {} : var.user_node_pool

  kubernetes_cluster_id       = azurerm_kubernetes_cluster.this.id
  name                        = each.value.name
  vm_size                     = each.value.vm_size
  mode                        = try(each.value.mode, "User")
  node_labels                 = each.value.labels
  node_taints                 = each.value.taints
  zones                       = each.value.availability_zones
  vnet_subnet_id              = try(each.value.node_subnet_id, var.node_subnet)
  pod_subnet_id               = try(var.network_plugin == "azure") ? var.node_subnet.id : null
  auto_scaling_enabled        = each.value.auto_scaling_enabled
  host_encryption_enabled     = each.value.host_encryption_enabled
  node_public_ip_enabled      = each.value.node_public_ip_enabled
  max_pods                    = each.value.max_pods
  max_count                   = var.system_node_pool.enable_auto_scaling == true ? var.system_node_pool.max_count : null
  min_count                   = var.system_node_pool.enable_auto_scaling == true ? var.system_node_pool.min_count : null
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

  tags = merge(
    try(var.tags),
    try(each.value.tags),
    tomap({
      "Resource Type" = "Kubernetes User Node"
    })
  )
}

resource "azurerm_route_table" "this" {
  count = var.outbound_type == "userDefinedRouting" ? 1 : 0

  name                           = var.route_table.name
  location                       = var.location
  resource_group_name            = var.resource_group_name
  tags                           = var.tags
  bgp_route_propagation_enabled  = var.route_table.bgp_route_propagation_enabled
}

resource "azurerm_subnet_route_table_association" "subnet_route_table" {
  count = var.outbound_type == "userDefinedRouting" ? 1 : 0

  subnet_id      = var.node_subnet
  route_table_id = azurerm_route_table.this[0].id

  depends_on = [ azurerm_route_table.this ]
}

resource "azurerm_role_assignment" "aks_vnet_rbac" {
  count = var.network_plugin == "azure" ? 0 : 1

  scope                = var.vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = data.azurerm_user_assigned_identity.k8s.principal_id

  depends_on = [ azurerm_route_table.this ]
}

resource "azurerm_role_assignment" "aks_dns" {
  count = var.network_plugin == "azure" ? 0 : 1

  scope                = var.private_dns_zone
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = data.azurerm_user_assigned_identity.k8s.principal_id
}
