# ========================================
# Network related variables
# ========================================
variable "node_subnet" {
  description = "The subnet for the k8s nodes"
  type        = string
}

variable "vnet_id" {
  description = "The ID of the VNet where the AKS cluster will be created"
  type        = string
  default     = null
}

variable "pod_subnet" {
  description = "(Optional) The subnet for the k8s pods when using azure cni"
  type        = string
  default     = null
}

variable "route_table" {
  description = "The route table to associate with the node subnet"
  type = object({
    name                          = optional(string, "aks-rt")
    route_name                    = optional(string, "fwroute")
    bgp_route_propagation_enabled = optional(bool, false)
    next_hop_in_ip_address        = optional(string)
    next_hop_type                 = optional(string, "VirtualAppliance")
    address_prefix                = optional(string, "0.0.0.0/0")
  })
  default = {}
}

variable "additional_routes" {
  type = map(object({
    name                   = optional(string)
    address_prefix         = optional(string)
    next_hop_type          = optional(string)
    next_hop_in_ip_address = optional(string)
  }))
  default     = null
  description = <<DESCRIPTION
"A map of additional routes for the route table, only add when you use userDefinedRouting"
- `name` - The name of the route.
- `address_prefix` - The address prefix for the route.
- `next_hop_type` - The type of the next hop, VirtualAppliance.
- `next_hop_in_ip_address` - The IP address of the next hop.

```
  additional_routes = {
    route1 = {
      name = "route1"
      address_prefix = "0.0.0.0/0"
      next_hop_type = "VirtualAppliance"
      next_hop_in_ip_address = "10.10.0.1"
    }
  }
```
DESCRIPTION
}

variable "api_server_access_profile" {
  type = object({
    authorized_ip_ranges = optional(set(string))
  })
  default     = null
  description = <<DESCRIPTION
The API server access profile for the Kubernetes cluster.
- `authorized_ip_ranges` - (Optional) Set of authorized IP ranges to allow access to API server, e.g. ["123.100.100.0/24"].
DESCRIPTION
}

# ========================================
# AKS variables
# ========================================
variable "kubernetes_version" {
  type    = string
  default = "1.31.5"
}

variable "local_account_disabled" {
  type        = bool
  default     = true
  description = "Whether or not the local account is disabled for the Kubernetes cluster, defaults to true."
}

variable "cost_analysis_enabled" {
  type        = bool
  default     = false
  description = "Whether or not cost analysis is enabled for the Kubernetes cluster. SKU must be Standard or Premium."

  validation {
    condition     = var.cost_analysis_enabled == false || var.sku_tier == "Standard" || var.sku_tier == "Premium"
    error_message = "Cost analysis can only be enabled for Standard or Premium SKU."
  }
}

variable "support_plan" {
  type        = string
  default     = "KubernetesOfficial"
  description = "The support plan for the Kubernetes cluster. Defaults to KubernetesOfficial."

  validation {
    condition     = can(index(["KubernetesOfficial", "AKSLongTermSupport"], var.support_plan))
    error_message = "The support plan must be one of: 'KubernetesOfficial' or 'AKSLongTermSupport'."
  }
}

variable "run_command_enabled" {
  type        = bool
  default     = false
  description = "Whether or not the run command is enabled for the Kubernetes cluster."
}

variable "image_cleaner_enabled" {
  type        = bool
  default     = false
  description = "Whether or not the image cleaner is enabled for the Kubernetes cluster."
}

variable "image_cleaner_interval_hours" {
  type        = number
  default     = null
  description = "(Optional) Specifies the interval in hours when images should be cleaned up. Defaults to `0`."

  validation {
    condition     = var.image_cleaner_interval_hours == null ? true : var.image_cleaner_interval_hours >= 24 && var.image_cleaner_interval_hours <= 2160
    error_message = "The image cleaner interval must be an int between 24 and 2160."
  }
}

variable "private_cluster_enabled" {
  description = "Should this Kubernetes Cluster have its API server only exposed on internal IP addresses? This provides a Private IP Address for the Kubernetes API on the Virtual Network where the Kubernetes Cluster is located. Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "automatic_upgrade_channel" {
  type        = string
  default     = null
  description = "(Optional) The upgrade channel for the AKS version of this Kubernetes Cluster. Possible values are `patch`, `rapid`, `node-image` and `stable`. By default automatic-upgrades are turned off. Note that you cannot specify the patch version using `kubernetes_version` or `orchestrator_version` when using the `patch` upgrade channel. See [the documentation](https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster) for more information"

  validation {
    condition = var.automatic_upgrade_channel == null ? true : contains([
      "patch", "stable", "rapid", "node-image"
    ], var.automatic_upgrade_channel)
    error_message = "`automatic_upgrade_channel`'s possible values are `patch`, `stable`, `rapid` or `node-image`."
  }
}

variable "node_os_upgrade_channel" {
  type        = string
  default     = "None"
  description = "(Optional) The upgrade channel for this Kubernetes Cluster. Possible values are `patch`, `rapid`, `node-image` and `stable`. By default automatic-upgrades are turned off. Note that you cannot specify the patch version using `kubernetes_version` or `orchestrator_version` when using the `patch` upgrade channel. See [the documentation](https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster) for more information"

  validation {
    condition = var.node_os_upgrade_channel == "None" ? true : contains([
      "Unmanaged", "SecurityPatch", "NodeImage"
    ], var.node_os_upgrade_channel)
    error_message = "`node_os_upgrade_channel`'s possible values are `Unmanaged`, `SecurityPatch` or `NodeImage`."
  }
}

variable "maintenance_window" {
    type = object({
    allowed = optional(object({
      day   = string
      hours = list(number)
    }))
    not_allowed = optional(object({
      end   = string
      start = string
    }))
  })
  default = null
  description = <<DESCRIPTION
"Configuration for the AKS cluster's general maintenance window. Set to null to disable this configuration. This will leave the scheduling up to microsoft."
- `allowed.day` - Day of the week when maintenance is allowed (e.g., "Saturday").
- `allowed.hours` - List of hours during the day when maintenance is allowed (e.g., [22, 23]).
- `not_allowed.end` - End time for the blackout period (RFC3339 format).
- `not_allowed.start` - Start time for the blackout period (RFC3339 format).
```
maintenance_window = {
  allowed = {
    day   = "Saturday"
    hours = [22, 23]
  }
  not_allowed = {
    end   = "2023-11-30T00:00:00Z"
    start = "2023-11-01T00:00:00Z"
  }
}
```
DESCRIPTION
}

variable "maintenance_window_node_os" {
  type = object({
    frequency   = string
    interval    = number
    duration    = number
    day_of_week = optional(string)
    week_index  = optional(string)
    start_time  = string
    utc_offset  = string
    start_date  = optional(string)
    not_allowed = optional(list(object({
      end       = string
      start     = string
    })))
  })
  default = null
  description = <<DESCRIPTION
"Configuration for the Node OS automatic upgrades maintenance window. Set to null to disable this configuration."
- `frequency` - Frequency of maintenance (e.g., "Weekly", "RelativeMonthly").
- `interval` - Interval between maintenance windows (e.g., 1 for every week or month).
- `duration` - Duration of the maintenance window in hours.
- `day_of_week` - Required for Weekly frequency (e.g., "Monday").
- `week_index` - Required for Monthly frequency (e.g., "First", "Second", "Last").
- `start_time` - Start time for maintenance in 24-hour format (e.g., "01:00").
- `utc_offset` - UTC offset for the maintenance window (e.g., "+00:00").
- `start_date` - (Optional) Start date for the maintenance window (RFC3339 format).
- `not_allowed` - (Optional) List of blackout periods with start and end times (RFC3339 format).
```
maintenance_window_node_os = {
  frequency   = "Weekly"
  interval    = 1
  duration    = 4
  day_of_week = "Monday"
  week_index  = "First"
  start_time  = "01:00"
  utc_offset  = "+00:00"
  start_date  = "2023-12-01T00:00:00Z"
  not_allowed = [
    {
    end   = "2023-12-31T00:00:00Z"
    start = "2023-12-24T00:00:00Z"
    }
  ]
}
```
DESCRIPTION
}

variable "maintenance_window_auto_upgrade" {
  type = object({
    frequency   = string
    interval    = number
    duration    = number
    day_of_week = optional(string)
    week_index  = optional(string)
    start_time  = string
    utc_offset  = string
    start_date  = optional(string)
    not_allowed = optional(list(object({
      end       = string
      start     = string
    })))
  })
  default = null
  description = <<DESCRIPTION
"Configuration for the AKS cluster version automatic upgrades maintenance window. Set to null to disable this configuration."
- `frequency` - Frequency of maintenance (e.g., "Weekly", "Monthly").
- `interval` - Interval between maintenance windows (e.g., 1 for every week or month).
- `duration` - Duration of the maintenance window in hours.
- `day_of_week` - Required for Weekly frequency (e.g., "Monday").
- `week_index` - Required for Monthly frequency (e.g., "First", "Second", "Last").
- `start_time` - Start time for maintenance in 24-hour format (e.g., "01:00").
- `utc_offset` - UTC offset for the maintenance window (e.g., "+00:00").
- `start_date` - (Optional) Start date for the maintenance window (RFC3339 format).
- `not_allowed` - (Optional) List of blackout periods with start and end times (RFC3339 format).
```
maintenance_window_auto_upgrade = {
  frequency   = "Weekly"
  interval    = 1
  duration    = 4
  day_of_week = "Monday"
  week_index  = "First"
  start_time  = "01:00"
  utc_offset  = "+00:00"
  start_date  = "2023-12-01T00:00:00Z"
  not_allowed = [
    {
    end   = "2023-12-31T00:00:00Z"
    start = "2023-12-24T00:00:00Z"
    }
  ]
}
```
DESCRIPTION
}


variable "sku_tier" {
  type        = string
  default     = "Standard"
  description = "The SKU tier of the Kubernetes Cluster. Possible values are Free, Standard, and Premium."

  validation {
    condition     = can(index(["Free", "Standard", "Premium"], var.sku_tier))
    error_message = "The SKU tier must be one of: 'Free', 'Standard', or 'Premium'. Free does not have an SLA."
  }
}

# Needed for oat2 proxy
variable "workload_identity_enabled" {
  description = "(Optional) Specifies whether Microsoft Entra ID Workload Identity should be enabled for the Cluster. Defaults to false."
  type        = bool
  default     = false
}

# Needed for oat2 proxy
variable "oidc_issuer_enabled" {
  description = "(Optional) Enable or Disable the OIDC issuer URL. To enable Azure AD Workload Identity oidc_issuer_enabled must be set to true. Enabling the OIDC issuer on an existing cluster changes the current service account token issuer to a new value, which can cause down time as it restarts the API server. If your application pods using a service token remain in a failed state after you enable the OIDC issuer, you may need to restart the pods. After you enable the OIDC issuer on the cluster, disabling it is not supported. The token needs to be refreshed periodically. If you use the SDK, the rotation is automatic. Otherwise, you need to refresh the token manually every 24 hours."
  type        = bool
  default     = false
}

variable "azure_policy_enabled" {
  description = "(Optional) Should the Azure Policy Add-On be enabled? For more details please visit Understand Azure Policy for Azure Kubernetes Service"
  type        = bool
  default     = true
}

variable "system_node_pool" {
  type = object({
    name                         = optional(string, "system")
    vm_size                      = optional(string, "Standard_B2s")
    temporary_name_for_rotation  = optional(string, "rtsystem")
    availability_zones           = optional(list(string), ["1", "2", "3"])
    node_labels                  = optional(map(any), {})
    only_critical_addons_enabled = optional(bool, true)
    auto_scaling_enabled         = optional(bool, false)
    host_encryption_enabled      = optional(bool, true)
    enable_node_public_ip        = optional(bool, false)
    max_pods                     = optional(number, 75)
    max_count                    = optional(number, 3)
    min_count                    = optional(number, 1)
    node_count                   = optional(number, 2)
    os_disk_type                 = optional(string, "Managed")
    os_disk_size_gb              = optional(number, null)
    pod_subnet_id                = optional(string)
    ultra_ssd_enabled            = optional(bool, false)
    os_sku                       = optional(string)
    upgrade_settings = optional(object({
      max_surge                     = optional(string, "10%")
      drain_timeout_in_minutes      = optional(number, 0)
      node_soak_duration_in_minutes = optional(number, 0)
    }), {})
    tags = optional(map(string), {})
  })
  default     = {}
  description = <<DESCRIPTION
The default node pool configuration for the Kubernetes Cluster.

- `name` - The name of the default node pool.
- `vm_size` - The VM size of the default node pool.
- `temporary_name_for_rotation` - The temporary name for the default node pool, during a roll over moment.
- `availability_zones` - The availability zones of the default node pool.
- `node_labels` - A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule).
- `only_critical_addons_enabled` - Enabling this option will taint default node pool with CriticalAddonsOnly=true:NoSchedule taint.
- `auto_scaling_enabled` - Whether to enable auto-scaler. Defaults to false.
- `host_encryption_enabled` - Should the nodes in this Node Pool have host encryption enabled? Defaults to false.
- `enable_node_public_ip` - Should each node have a Public IP Address? Defaults to false.
- `max_pods` - The maximum number of pods that can run on each agent.
- `max_count` - The maximum number of nodes which should exist within this Node Pool.
- `min_count` - The minimum number of nodes which should exist within this Node Pool.
- `node_count` - The initial number of nodes which should exist within this Node Pool.
- `os_disk_type` - The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed.
- `os_disk_size_gb` - The size of the OS disk in GB.
- `os_sku` - Specifies the OS SKU used by the agent pool. Possible values are AzureLinux, Ubuntu, Windows2019, and Windows2022. Defaults to Ubuntu if OSType=Linux or Windows2019 if OSType=Windows.
- `upgrade_settings` - The upgrade settings for the default node pool.
  - `max_surge` - The maximum number of nodes that can be added during an upgrade, as a percentage of the total number of nodes, default is 10%.
  - `drain_timeout_in_minutes` - The maximum amount of time to wait for a node to drain during an upgrade, default is 0.
  - `node_soak_duration_in_minutes` - The maximum amount of time to wait for a node to soak after draining during an upgrade, default is 0.
- `tags` - A map of tags to assign to the resource.
DESCRIPTION

  validation {
    condition     = can(regex("^([a-z][a-z0-9]{0,11})$", var.system_node_pool.temporary_name_for_rotation))
    error_message = "The temporary_name_for_rotation must begin with a lowercase letter, contain only lowercase letters and numbers, and be between 1 and 12 characters in length."
  }
}

variable "user_node_pool" {
  type = map(object({
    name                        = optional(string, null)
    vm_size                     = optional(string, "Standard_D2s_v5")
    mode                        = optional(string, "User")
    node_labels                 = optional(map(any), {})
    node_taints                 = optional(list(string), [])
    availability_zones          = optional(list(string), ["1", "2", "3"])
    auto_scaling_enabled        = optional(bool, false)
    host_encryption_enabled     = optional(bool, true)
    node_public_ip_enabled      = optional(bool, false)
    max_pods                    = optional(number, 100)
    max_count                   = optional(number, 3)
    min_count                   = optional(number, 1)
    node_count                  = optional(number, 2)
    os_disk_size_gb             = optional(number, null)
    os_disk_type                = optional(string, "Managed")
    ultra_ssd_enabled           = optional(bool, false)
    os_type                     = optional(string)
    os_sku                      = optional(string)
    temporary_name_for_rotation = optional(string, "rtuser")
    pod_subnet_id               = optional(string, null)
    vnet_subnet_id              = optional(string, null)
    upgrade_settings = optional(object({
      max_surge                     = optional(string, "10%")
      drain_timeout_in_minutes      = optional(number, 0)
      node_soak_duration_in_minutes = optional(number, 0)
    }), {})
    tags = optional(map(string), {})
  }))
  default     = {}
  description = <<DESCRIPTION
The user node pool configuration for the Kubernetes Cluster.

- `name` - The name of the user node pool.
- `vm_size` - The VM size of the user node pool.
- `mode` - The mode of the user node pool.
- `node_labels` - A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule).
- `node_taints` - A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule).
- `availability_zones` - The availability zones of the user node pool.
- `auto_scaling_enabled` - Whether to enable auto-scaler. Defaults to false.
- `host_encryption_enabled` - Should the nodes in this Node Pool have host encryption enabled? Defaults to false.
- `node_public_ip_enabled` - Should each node have a Public IP Address? Defaults to false.
- `max_pods` - The maximum number of pods that can run on each agent.
- `max_count` - The maximum number of nodes which should exist within this Node Pool.
- `min_count` - The minimum number of nodes which should exist within this Node Pool.
- `count` - The initial number of nodes which should exist within this Node Pool.
- `os_disk_size_gb` - The size of the OS disk in GB.
- `os_disk_type` - The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Ephemeral.
- `os_type` - The type of OS which should be used for the Operating System. Possible values are Linux and Windows. Defaults to Linux.
- `os_sku` - Specifies the OS SKU used by the agent pool. Possible values are AzureLinux, Ubuntu, Windows2019, and Windows2022. Defaults to Ubuntu if OSType=Linux or Windows2019 if OSType=Windows.
- `temporary_name_for_rotation` - The temporary name for the user node pool, during a roll over moment, default is rotation, if not set.
- `pod_subnet_id` - The subnet for the k8s pods when using azure cni.
- `vnet_subnet_id` - The subnet for the k8s nodes.
- `tags` - A map of tags to assign to the resource.
DESCRIPTION
}

variable "linux_profile" {
  description = "(Optional) The Linux Profile to use for the default node pool."
  type = object({
    admin_username = optional(string)
    ssh_key = optional(object({
      key_data = string
    }))
  })
  default = null
}

variable "defender_log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "The log analytics workspace ID for the Microsoft Defender."
}

variable "disk_encryption_set_id" {
  description = "(Optional) The ID of the Disk Encryption Set which should be used for this Kubernetes Cluster. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "azure_active_directory_role_based_access_control" {
  type = object({
    tenant_id              = optional(string)
    admin_group_object_ids = optional(list(string))
    azure_rbac_enabled     = optional(bool, true)
  })
  default     = null
  description = <<DESCRIPTION
The Azure Active Directory Role Based Access Control configuration for the Kubernetes cluster.

- `tenant_id` - (Optional) The Tenant ID used for Azure Active Directory Application. If this isn't specified the Tenant ID of the current Subscription is used.
- `admin_group_object_ids` - (Optional) A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster.
- `azure_rbac_enabled` - (Optional) Is Role Based Access Control based on Azure AD enabled?
DESCRIPTION
}

variable "workload_autoscaler_profile" {
  type = object({
    keda_enabled                    = optional(bool)
    vertical_pod_autoscaler_enabled = optional(bool)
  })
  default     = null
  description = "The workload autoscaler profile for the Kubernetes cluster."
}

variable "diagnostic_settings" {
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = <<-DESCRIPTION
  A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.
DESCRIPTION
  nullable    = false

  validation {
    condition     = alltrue([for _, v in var.diagnostic_settings : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
  validation {
    condition = alltrue(
      [
        for _, v in var.diagnostic_settings :
        v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
      ]
    )
    error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id`, must be set."
  }
}

variable "network_profile" {
  type = object({
    network_plugin      = optional(string, "azure")
    dns_service_ip      = optional(string)
    network_mode        = optional(string)
    network_policy      = optional(string)
    network_data_plane  = optional(string)
    network_plugin_mode = optional(string)
    outbound_type       = optional(string, "loadBalancer")
    pod_cidr            = optional(string)
    pod_cidrs           = optional(list(string))
    service_cidr        = optional(string, null)
    service_cidrs       = optional(list(string))
    ip_versions         = optional(list(string))
    load_balancer_sku   = optional(string)
    load_balancer_profile = optional(object({
      managed_outbound_ip_count   = optional(number)
      managed_outbound_ipv6_count = optional(number)
      outbound_ip_address_ids     = optional(list(string))
      outbound_ip_prefix_ids      = optional(list(string))
      outbound_ports_allocated    = optional(number)
      idle_timeout_in_minutes     = optional(number)
    }))
    nat_gateway_profile = optional(object({
      managed_outbound_ip_count = optional(number)
      idle_timeout_in_minutes   = optional(number)
    }))
  })
  default     = {}
  description = <<DESCRIPTION

  "The network profile for the Kubernetes cluster."

  - `network_plugin` - The network plugin to use for networking. Possible values are azure and kubenet and none (BYOCNI). Defaults to azure. When network_plugin is set to azure - the pod_cidr field must not be set, unless specifying network_plugin_mode to overlay.
  - `service_cidr` - The CIDR to use for service cluster IP addresses. This must not overlap with any Subnet IP ranges. Changing this forces a new resource to be created.
  - `service_cidrs` - The CIDRs to use for service cluster IP addresses. This must not overlap with any Subnet IP ranges. Changing this forces a new resource to be created.
  - `dns_service_ip` - The IP address of the Kubernetes DNS service. This must be within the Kubernetes service address range specified by service_cidr.
  - `network_mode` - The network mode used for building the Kubernetes network. Possible values are transparent and overlay.
  - `network_policy` - Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods. Currently supported values are calico, azure and cilium. When network_policy is set to azure, the network_plugin field can only be set to azure. When network_policy is set to cilium, the network_data_plane field must be set to cilium.
  - `network_data_plane` - Specifies the data plane used for building the Kubernetes network. Possible values are azure and cilium. Defaults to azure. Disabling this forces a new resource to be created. When network_data_plane is set to cilium, the network_plugin field can only be set to azure. When network_data_plane is set to cilium, one of either network_plugin_mode = overlay or pod_subnet_id must be specified.
  - `network_plugin_mode` - Specifies the network plugin mode used for building the Kubernetes network. Possible value is overlay, defaults to null.
  - `outbound_type` - The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are loadBalancer, userDefinedRouting, managedNATGateway and userAssignedNATGateway. Defaults to loadBalancer.
  - `pod_cidr` - The CIDR to use for pod IP addresses. This field can only be set when network_plugin is set to kubenet or network_plugin_mode is set to overlay. Changing this forces a new resource to be created.
  - `pod_cidrs` - The CIDRs to use for pod IP addresses. This field can only be set when network_plugin is set to kubenet or network_plugin_mode is set to overlay. Changing this forces a new resource to be created.
  - `ip_versions` - The IP versions to use for the Kubernetes cluster. Possible values are IPv4 and IPv6.
  - `load_balancer_sku` - The SKU of the Load Balancer which should be used for this Kubernetes Cluster. Possible values are standard and basic. Defaults to standard.
  - `load_balancer_profile` - The load balancer profile for the Kubernetes cluster.
  - `nat_gateway_profile` - The NAT gateway profile for the Kubernetes cluster.
  DESCRIPTION

  validation {
    condition     = !((var.network_profile.load_balancer_profile != null) && var.network_profile.load_balancer_sku != "standard")
    error_message = "Enabling load_balancer_profile requires that `load_balancer_sku` be set to `standard`"
  }
  validation {
    condition     = var.network_profile.network_mode != "overlay" || var.network_profile.network_plugin == "azure"
    error_message = "When network_plugin_mode is set to `overlay`, the network_plugin field can only be set to azure."
  }
  validation {
    condition     = var.network_profile.network_policy != "cilium" || var.network_profile.network_plugin == "azure"
    error_message = "When the network policy is set to cilium, the network_plugin field can only be set to azure."
  }
  validation {
    condition     = var.network_profile.network_policy != "cilium" || var.network_profile.network_plugin_mode == "overlay" || var.system_node_pool.pod_subnet_id != null
    error_message = "When the network policy is set to cilium, one of either network_plugin_mode = `overlay` or pod_subnet_id must be specified."
  }
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

# ========================================
# General AKS Configuration
# ========================================
variable "kubernetes_cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the AKS cluster will be created"
  type        = string
}

variable "location" {
  description = "The Azure region where the AKS cluster will be created"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix specified when creating the managed cluster. Changing this forces a new resource to be created"
  type        = string
}

variable "private_dns_zone_id" {
  description = "The ID of Private DNS Zone which should be delegated to this Cluster. Required when private_cluster_enabled is true"
  type        = string
  default     = null
}

variable "node_resource_group_name" {
  description = "The name of the Resource Group where the Kubernetes Nodes should exist"
  type        = string
}

# ========================================
# Identity Configuration
# ========================================
variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Controls the Managed Identity configuration on this resource. The following properties can be specified:

although system_assigned is possible, it is not recommended since you can't really use it with private dns zones.

- `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
- `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.
DESCRIPTION
  nullable    = false

  validation {
    condition     = !(var.managed_identities.system_assigned && var.private_cluster_enabled)
    error_message = "System assigned managed identity cannot be used when private_cluster_enabled is true."
  }
}

variable "kubelet_identity" {
  type = object({
    client_id                 = optional(string)
    object_id                 = optional(string)
    user_assigned_identity_id = optional(string)
  })
  default     = null
  description = "The kubelet identity for the Kubernetes cluster."
}