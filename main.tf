resource "azurerm_kubernetes_cluster" "this" {
  name                      = var.kubernetes_cluster_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  kubernetes_version        = var.kubernetes_version
  dns_prefix                = var.dns_prefix
  private_cluster_enabled   = var.private_cluster_enabled
  private_dns_zone_id       = var.private_cluster_enabled == true ? var.private_dns_zone : null
  automatic_upgrade_channel = var.automatic_upgrade_channel
  sku_tier                  = var.sku_tier
  workload_identity_enabled = var.workload_identity_enabled
  oidc_issuer_enabled       = var.oidc_issuer_enabled
  azure_policy_enabled      = var.azure_policy_enabled
  tags                      = var.tags

  node_resource_group = var.node_resource_group_name

  default_node_pool {
    name           = var.system_node_name
    vm_size        = var.system_node_vm_size
    vnet_subnet_id = var.node_subnet
    pod_subnet_id  = try(var.network_plugin == "azure") ? var.pod_subnet : null

    zones                        = var.system_node_availability_zones
    node_labels                  = var.system_node_node_labels
    only_critical_addons_enabled = var.only_critical_addons_enabled
    auto_scaling_enabled         = var.system_node_enable_auto_scaling
    host_encryption_enabled      = var.system_node_enable_host_encryption
    node_public_ip_enabled       = var.system_node_enable_node_public_ip
    max_pods                     = var.system_node_max_pods
    max_count                    = var.system_node_enable_auto_scaling == true ? var.system_node_max_count : null
    min_count                    = var.system_node_enable_auto_scaling == true ? var.system_node_min_count : null
    node_count                   = var.system_node_count
    os_disk_type                 = var.system_node_os_disk_type
    tags                         = var.tags
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
    identity_ids = tolist([try(data.azurerm_user_assigned_identity.k8s.id, var.user_assigned_identity_id)])
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

  workload_autoscaler_profile {
    keda_enabled                    = var.keda_enabled
    vertical_pod_autoscaler_enabled = var.vertical_pod_autoscaler_enabled
  }

  lifecycle {
    ignore_changes = [
      kubernetes_version
    ]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = var.user_node_pool == null ? {} : var.user_node_pool

  kubernetes_cluster_id   = azurerm_kubernetes_cluster.this.id
  name                    = each.value.name
  vm_size                 = each.value.vm_size
  mode                    = try(each.value.mode, "User")
  node_labels             = each.value.labels
  node_taints             = each.value.taints
  zones                   = each.value.availability_zones
  vnet_subnet_id          = var.node_subnet
  pod_subnet_id           = try(var.network_plugin != "azure") ? var.node_subnet.id : null
  auto_scaling_enabled    = each.value.auto_scaling_enabled
  host_encryption_enabled = each.value.host_encryption_enabled
  node_public_ip_enabled  = each.value.node_public_ip_enabled
  max_pods                = each.value.max_pods
  max_count               = each.value.max_count
  min_count               = each.value.min_count
  node_count              = each.value.node_count
  os_disk_size_gb         = each.value.os_disk_size_gb
  os_disk_type            = each.value.os_disk_type
  os_type                 = each.value.os_type
  tags                    = var.tags
}

resource "azurerm_route_table" "this" {
  count = var.network_plugin == "azure" ? 0 : 1

  name                           = var.route_table.name
  location                       = var.location
  resource_group_name            = var.resource_group_name
  tags                           = var.tags
  bgp_route_propagation_enabled  = var.route_table.bgp_route_propagation_enabled
}

resource "azurerm_subnet_route_table_association" "subnet_route_table" {
  count = var.network_plugin == "azure" ? 0 : 1

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

