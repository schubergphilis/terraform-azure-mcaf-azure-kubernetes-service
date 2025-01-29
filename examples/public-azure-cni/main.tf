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
    Environment = "azure-demos"
    owner       = "Owner"
  }
}

resource "azurerm_resource_group" "pubazurecnidemo" {
  name     = "akspubazurecnidemo"
  location = "germanywestcentral"
  tags     = local.tags
}

resource "azurerm_virtual_network" "pubazurecnidemo" {
  name                = "pubazurecnidemo-vnet"
  address_space       = ["192.168.8.0/22"]
  location            = azurerm_resource_group.pubazurecnidemo.location
  resource_group_name = azurerm_resource_group.pubazurecnidemo.name
  tags                = local.tags
}
resource "azurerm_subnet" "pubazurecnidemo-node" {
  name                 = "pubazurecnidemo-node-subnet"
  resource_group_name  = azurerm_resource_group.pubazurecnidemo.name
  virtual_network_name = azurerm_virtual_network.pubazurecnidemo.name
  address_prefixes     = ["192.168.9.0/24"]
}
resource "azurerm_subnet" "pubazurecnidemo-endpoint" {
  name                 = "pubazurecnidemo-endpoint-subnet"
  resource_group_name  = azurerm_resource_group.pubazurecnidemo.name
  virtual_network_name = azurerm_virtual_network.pubazurecnidemo.name
  address_prefixes     = ["192.168.10.0/24"]
}

# Create the managed identity separately
resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "aks-kubenet-demo-identity"
  resource_group_name = azurerm_resource_group.pubazurecnidemo.name
  location            = azurerm_resource_group.pubazurecnidemo.location
}

module "aks" {
  source = "../../"
  //depends_on = [ azurerm_role_assignment.aks_vnet_rbac ]

  # Pass the identity to the module
  user_assigned_identity_id = azurerm_user_assigned_identity.aks_identity.id

  location = azurerm_resource_group.pubazurecnidemo.location

  # Required networking variables
  dns_service_ip = "10.0.0.10"
  service_cidr   = "10.0.0.0/16"

  node_subnet     = azurerm_subnet.pubazurecnidemo-node.id
  endpoint_subnet = azurerm_subnet.pubazurecnidemo-endpoint.id

  # AKS Configuration
  kubernetes_cluster_name  = "pubazurecnidemo-aks"
  resource_group_name      = azurerm_resource_group.pubazurecnidemo.name
  dns_prefix               = "pubazurecnidemo"
  node_resource_group_name = "akspubazurecnidemo-nodes"

  kubernetes_version      = "1.28.9"
  network_plugin          = "azure"
  network_policy          = "azure"
  private_cluster_enabled = false

  # Optional features
  workload_identity_enabled = true
  oidc_issuer_enabled       = true
  azure_policy_enabled      = true

  # System node pool configuration
  system_node_name     = "system"
  system_node_vm_size  = "Standard_B2s"
  system_node_count    = 2
  system_node_max_pods = 50
  # Required for RBAC
  aks_administrators = [""] # Replace with actual admin group ID

  tags = local.tags
}
