terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0, < 5.0.0"
    }
  }
}

provider "azurerm" {
  subscription_id = ""
  features {}
}

locals {
  tags = {
    environment = "dev"
    costcenter  = "12345"
  }
  ip_rules = ["123.123.123.123"]
}

resource "azurerm_resource_group" "rsg" {
  name     = "resourcegroupaks"
  location = "westeurope"

  tags = local.tags
}

data "azurerm_client_config" "current" {}

module "key_vault" {
  source = "github.com/schubergphilis/terraform-azure-mcaf-key-vault?ref=v0.3.2"

  key_vault = {
    name                          = "keyvaultaks"
    resource_group_name           = azurerm_resource_group.rsg.name
    location                      = azurerm_resource_group.rsg.location
    tenant_id                     = data.azurerm_client_config.current.tenant_id
    public_network_access_enabled = false
    network_bypass                = "AzureServices" #required for disk encryption set
    ip_rules                      = local.ip_rules
    soft_delete_retention_days    = 7
    purge_protection              = true
  }

  key_vault_key = {
    cmk-des-step = {
      type = "RSA"
      size = 4096
      opts = ["wrapKey", "unwrapKey"]
      rotation_policy = {
        automatic = {
          time_after_creation = "P18M"
        }
        expire_after         = "P2Y"
        notify_before_expiry = "P30D"
      }
    }
  }

  tags = var.tags
}

module "network" {
  source = "github.com/schubergphilis/terraform-azure-mcaf-network?ref=v0.4.3"

  resource_group = {
    name     = "resourcegroupaksvnet"
    location = "westeurope"
  }

  vnet_name          = "vnetaks"
  vnet_address_space = ["100.0.0.0/16"]
  subnets = {
    "AKSNodeSubnet" = {
      address_prefixes                = ["100.0.1.0/25"]
      default_outbound_access_enabled = false
      create_network_security_group   = true
      network_security_group_config = {
        azure_default = true
      }
    }
    "AKSEPSubnet" = {
      address_prefixes                = ["100.0.1.128/25"]
      default_outbound_access_enabled = false
      create_network_security_group   = true
      network_security_group_config = {
        azure_default = true
      }
    }
  }

  tags = var.tags
}

module "des" {
  source                    = "github.com/schubergphilis/terraform-azure-mcaf-diskencryptionset?ref=v0.1.0"
  name                      = "desaks"
  resource_group_name       = azurerm_resource_group.rsg.name
  location                  = azurerm_resource_group.rsg.location
  key_vault_key_id          = module.key_vault.cmkrsa_versionless_id
  key_vault_resource_id     = module.key_vault.key_vault_id
  auto_key_rotation_enabled = true
  managed_identities = {
    system_assigned = true
  }
}

# Create the managed identity separately
resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "aksclusteridentity"
  resource_group_name = azurerm_resource_group.rsg.name
  location            = azurerm_resource_group.rsg.location
}

resource "azurerm_user_assigned_identity" "kubelet_identity" {
  name                = "akskubeletidentity"
  resource_group_name = azurerm_resource_group.rsg.name
  location            = azurerm_resource_group.rsg.location
}

resource "azurerm_private_dns_zone" "aks" {
  name                = "aks123.privatelink.westeurope.azmk8s.io"
  resource_group_name = azurerm_resource_group.rsg.name
}

module "aks" {
  source = "../../"

  resource_group_name = azurerm_resource_group.rsg.name
  location            = azurerm_resource_group.rsg.location

  # Pass the identity to the module
  control_plane_user_assigned_identity_id = azurerm_user_assigned_identity.aks_identity.id

  vnet_id     = module.network.id
  node_subnet = module.network.subnets["AKSNodeSubnet"].id

  network_profile = {
    outbound_type       = "loadBalancer"
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    dns_service_ip      = "10.0.0.10"
    service_cidr        = "10.0.0.0/16"
  }

  # AKS Configuration
  kubernetes_cluster_name  = "akscluster"
  dns_prefix               = "akscluster"
  node_resource_group_name = "${azurerm_resource_group.rsg.name}-nodes"
  disk_encryption_set_id   = module.des.resource_id

  private_cluster_enabled = false
  api_server_access_profile = {
    authorized_ip_ranges = ["123.123.123.123/32"]
  }

  kubernetes_version      = "1.31.5"
  private_dns_zone_id     = azurerm_private_dns_zone.aks.id

  user_node_pool = {
    pool1 = {
      name         = "pool1"
      vm_size      = "Standard_B2s"
      os_disk_type = "Managed"
      min_count    = 1
      max_count    = 3
      node_count   = 2
    }
  }

  kubelet_user_assigned_identity_id = {
    user_managed_identity = azurerm_user_assigned_identity.kubelet_identity.id
  }

  aks_administrators = ["00000000-0000-0000-0000-000000000000"] # Replace with actual admin group ID

  tags = local.tags
}

module "container_registry" {
  source = "github.com/schubergphilis/terraform-azure-mcaf-container-registry?ref=v0.1.2"

  acr = {
    name                = "acraks"
    resource_group_name = azurerm_resource_group.rsg.name
    location            = azurerm_resource_group.rsg.location

    role_assignments = {
      acr = {
        role_definition_name = "AcrPull"
        principal_id         = azurerm_user_assigned_identity.kubelet_identity.principal_id
      }
    }
  }

  tags = local.tags
}
