# ========================================
# Network related variables
# ========================================
variable "routes" {
  description = "A list of routes"
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = null
}



variable "endpoint_subnet" {
  description = "The subnet for the api endpoint"
  type = string
}

variable "node_subnet" {
  description = "The subnet for the k8s nodes"
  type = string
}

variable "pod_subnet" {
  description = "(Optional) The subnet for the k8s pods when using azure cni"
  type = string
  default = null
}


# ========================================
# AKS variables
# ========================================
variable "kubernetes_version" {
  type    = string
  default = "1.28.9"
}

variable "network_proxy_disabled" {
  description = "Should the Kubernetes Cluster have the kube-proxy disabled? Defaults to false."
  type        = bool
  default     = false
}

variable "private_cluster_enabled" {
  description = "Should this Kubernetes Cluster have its API server only exposed on internal IP addresses? This provides a Private IP Address for the Kubernetes API on the Virtual Network where the Kubernetes Cluster is located. Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "automatic_upgrade_channel" {
  description = "(Optional) The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, node-image and stable. Omitting this field sets this value to none."
  default     = null
  type        = string
}

variable "sku_tier" {
  description = "(Optional) The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid (which includes the Uptime SLA). Defaults to Free."
  default     = "Free"
  type        = string

  validation {
    condition     = contains(["Free", "Paid"], var.sku_tier)
    error_message = "The sku tier is invalid."
  }
}

# Needed for oat2 proxy
variable "workload_identity_enabled" {
  description = "(Optional) Specifies whether Microsoft Entra ID Workload Identity should be enabled for the Cluster. Defaults to false."
  type        = bool
  default     = true
}

# Needed for oat2 proxy
variable "oidc_issuer_enabled" {
  description = "(Optional) Enable or Disable the OIDC issuer URL. To enable Azure AD Workload Identity oidc_issuer_enabled must be set to true. Enabling the OIDC issuer on an existing cluster changes the current service account token issuer to a new value, which can cause down time as it restarts the API server. If your application pods using a service token remain in a failed state after you enable the OIDC issuer, you may need to restart the pods. After you enable the OIDC issuer on the cluster, disabling it is not supported. The token needs to be refreshed periodically. If you use the SDK, the rotation is automatic. Otherwise, you need to refresh the token manually every 24 hours."
  type        = bool
  default     = true
}

variable "azure_policy_enabled" {
  description = "(Optional) Should the Azure Policy Add-On be enabled? For more details please visit Understand Azure Policy for Azure Kubernetes Service"
  type        = bool
  default     = true
}

variable "system_node_name" {
  description = "Specifies the name of the default node pool"
  default     = "system"
  type        = string
}

variable "system_node_vm_size" {
  description = "Specifies the vm size of the default node pool"
  default     = "Standard_D2s_v5"
  type        = string
}

variable "system_node_availability_zones" {
  description = "Specifies the availability zones of the default node pool"
  default     = ["1", "2", "3"]
  type        = list(string)
}

variable "system_node_node_labels" {
  description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
  type        = map(any)
  default     = {}
}

variable "only_critical_addons_enabled" {
  description = "(Optional) Enabling this option will taint default node pool with CriticalAddonsOnly=true:NoSchedule taint. Changing this forces a new resource to be created."
  type        = bool
  default     = true
}

variable "system_node_enable_auto_scaling" {
  description = "(Optional) Whether to enable auto-scaler. Defaults to false."
  type        = bool
  default     = false
}

variable "system_node_enable_host_encryption" {
  description = "(Optional) Should the nodes in this Node Pool have host encryption enabled? Defaults to false."
  type        = bool
  default     = false
}

variable "system_node_enable_node_public_ip" {
  description = "(Optional) Should each node have a Public IP Address? Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "system_node_max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  type        = number
  default     = 250
}

variable "system_node_max_count" {
  description = "(Required) The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count."
  type        = number
  default     = 3
}

variable "system_node_min_count" {
  description = "(Required) The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count."
  type        = number
  default     = 1
}

variable "system_node_count" {
  description = "(Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be a value in the range min_count - max_count."
  type        = number
  default     = 2
}

# TODO: need to choose
variable "system_node_os_disk_type" {
  description = "(Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created."
  type        = string
  default     = "Managed"
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

# TODO
# variable "aks_managed_identity" {
#   description = "The Managed Identity to use for the AKS Cluster."
#   type        = list(string)
# }

variable "route_table" {
  description = "The route table to associate with the node subnet"
  type = object({
    name = optional(string, "aks-rt")
    bgp_route_propagation_enabled = optional(bool, false)
  })
  default = {}
}

variable "network_plugin" {
  description = "The network plugin to use for networking. Possible values are azure and kubenet. Defaults to azure. When network_plugin is set to azure - the pod_cidr field must not be set, unless specifying network_plugin_mode to overlay."
  type        = string
  default     = "none"
  validation {
    condition     = contains(["azure", "kubenet", "none"], var.network_plugin)
    error_message = "The network plugin is invalid."
  }
}

variable "vnet_id" {
  description = "The ID of the VNet where the AKS cluster will be created"
  type        = string
  default     = null
}

variable "network_plugin_mode" {
  description = "(Optional) Specifies the network plugin mode used for building the Kubernetes network. Possible value is overlay."
  default     = null
}
variable "dns_service_ip" {
  description = "Specifies the DNS service IP"
  type        = string
}

variable "outbound_type" {
  description = "(Optional) The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are loadBalancer, userDefinedRouting, managedNATGateway and userAssignedNATGateway. Defaults to loadBalancer. Defaults to loadBalancer."
  type        = string
  default     = "userDefinedRouting"

  validation {
    condition     = contains(["loadBalancer", "userDefinedRouting", "managedNATGateway", "userAssignedNATGateway"], var.outbound_type)
    error_message = "The outbound type is invalid."
  }
}

variable "pod_cidr" {
  description = "(Optional) The CIDR to use for pod IP addresses. This field can only be set when network_plugin is set to kubenet or network_plugin_mode is set to overlay. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "service_cidr" {
  description = "(Optional) The Network Range used by the Kubernetes service. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "bgp_route_propagation_enabled" {
  type    = bool
  default = false
}

# variable "network_data_plane" {
#   description = "(Optional) Specifies the data plane used for building the Kubernetes network. Possible values are azure and cilium. Defaults to azure. Disabling this forces a new resource to be created. When network_data_plane is set to cilium, the network_plugin field can only be set to azure. When network_data_plane is set to cilium, one of either network_plugin_mode = overlay or pod_subnet_id must be specified."
#   type        = string
#   default     = "azure"

#   validation {
#     condition     = contains(["azure", "cilium"], var.network_data_plane)
#     error_message = "The network data plane is invalid."
#   }
# }

variable "network_policy" {
  description = "(Optional) Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods. Currently supported values are calico, azure and cilium. When network_policy is set to azure, the network_plugin field can only be set to azure. When network_policy is set to cilium, the network_data_plane field must be set to cilium."
  type        = string
  default     = "azure"
  validation {
    condition     = contains(["calico", "azure", "cilium"], var.network_policy)
    error_message = "The network policy is invalid."
  }
}

variable "disk_encryption_set_id" {
  description = "(Optional) The ID of the Disk Encryption Set which should be used for this Kubernetes Cluster. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "load_balancer_sku" {
  description = "(Optional) The SKU of the Load Balancer which should be used for this Kubernetes Cluster. Possible values are standard and basic. Defaults to standard."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "basic"], var.load_balancer_sku)
    error_message = "The load balancer sku is invalid."
  }

}
variable "azure_rbac_enabled" {
  description = "(Optional) Should Azure RBAC be enabled for this Kubernetes Cluster? Defaults to true."
  type        = bool
  default     = true
}
variable "admin_group_object_ids" {
  description = "(Optional) A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster."
  type        = list(string)
  default     = []
}

variable "keda_enabled" {
  description = "(Optional) Should KEDA be enabled for this Kubernetes Cluster? Defaults to false."
  type        = bool
  default     = false
}

variable "vertical_pod_autoscaler_enabled" {
  description = "(Optional) Should Vertical Pod Autoscaler be enabled for this Kubernetes Cluster? Defaults to false."
  type        = bool
  default     = false
}

variable "aks_cluster_administrators" {
  description = "(Optional) A list of Object IDs of Azure Active Directory Users/Groups which should have Admin Role on the Cluster."
  type        = list(string)
  default     = []
}

variable "diagnostic_settings" {
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
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

variable "user_node_pool" {
  type = map(object({
    name                    = optional(string, null)
    vm_size                 = optional(string, "Standard_D2s_v5")
    mode                    = optional(string, "User")
    labels                  = optional(map(any), {})
    taints                  = optional(list(string), [])
    availability_zones      = optional(list(string), ["1", "2", "3"])
    auto_scaling_enabled    = optional(bool, false)
    host_encryption_enabled = optional(bool, false)
    node_public_ip_enabled  = optional(bool, false)
    max_pods                = optional(number, 250)
    max_count               = optional(number, 3)
    min_count               = optional(number, 1)
    node_count              = optional(number, 1)
    os_disk_size_gb         = optional(number, 100)
    os_disk_type            = optional(string, "Ephemeral")
    os_type                 = optional(string, "Linux")
  }))
  default  = {}
  nullable = false
}

# ========================================
# Storage account variables
# ========================================
variable "diagnostic_settings_storage_account" {
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
  default  = {}
  nullable = false

  validation {
    condition     = alltrue([for _, v in var.diagnostic_settings_storage_account : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
  description = <<DESCRIPTION
A map of diagnostic settings to create on the Storage Account. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

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
}

variable "diagnostic_settings_blob" {
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
  default  = {}
  nullable = false

  validation {
    condition     = alltrue([for _, v in var.diagnostic_settings_blob : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
  description = <<DESCRIPTION
A map of diagnostic settings to create on the Blob Storage within Storage Account. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

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
}

variable "additional_account_role_assignments" {
  type = map(object({
    role_definition_name                   = optional(string, null)
    role_definition_id                     = optional(string, null)
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on the resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
  nullable    = false
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

variable "dns_prefix" {
  description = "DNS prefix specified when creating the managed cluster. Changing this forces a new resource to be created"
  type        = string
}

variable "private_dns_zone" {
  description = "The ID of Private DNS Zone which should be delegated to this Cluster. Required when private_cluster_enabled is true"
  type        = string
  default     = null
}

variable "node_resource_group_name" {
  description = "The name of the Resource Group where the Kubernetes Nodes should exist"
  type        = string
}

# ========================================
# AAD Integration
# ========================================
variable "aks_administrators" {
  description = "A list of Azure AD group object IDs that will have the admin role of the cluster"
  type        = list(string)
}

variable "location" {
  description = "The Azure region where the AKS cluster will be created"
  type        = string
}

# ========================================
# Identity Configuration
# ========================================
variable "user_assigned_identity_id" {
  description = "The ID of the User Assigned Identity that will be used by the AKS cluster. If not provided, a managed identity will be created."
  type        = string
  default     = null
}
