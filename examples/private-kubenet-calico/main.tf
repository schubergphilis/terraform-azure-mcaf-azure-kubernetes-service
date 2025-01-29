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

resource "azurerm_resource_group" "kubenetdemo" {
  name     = "akskubenetdemo"
  location = "germanywestcentral"
  tags     = local.tags
}

resource "azurerm_virtual_network" "kubenetdemo" {
  name                = "kubenetdemo-vnet"
  address_space       = ["192.168.8.0/22"]
  location            = azurerm_resource_group.kubenetdemo.location
  resource_group_name = azurerm_resource_group.kubenetdemo.name
  tags                = local.tags
}
resource "azurerm_subnet" "kubenetdemo-node" {
  name                 = "kubenetdemo-node-subnet"
  resource_group_name  = azurerm_resource_group.kubenetdemo.name
  virtual_network_name = azurerm_virtual_network.kubenetdemo.name
  address_prefixes     = ["192.168.9.0/24"]
}
resource "azurerm_subnet" "kubenetdemo-endpoint" {
  name                 = "kubenetdemo-endpoint-subnet"
  resource_group_name  = azurerm_resource_group.kubenetdemo.name
  virtual_network_name = azurerm_virtual_network.kubenetdemo.name
  address_prefixes     = ["192.168.10.0/24"]
}

# Only deploy route table if cluster is private and network_plugin is kubenet
module "aks_route_table" {
  source = "git::https://github.com/schubergphilis/terraform-azure-mcaf-route-table?ref=main"

  name                = "azurekubernetdemo-rt"
  location            = azurerm_resource_group.kubenetdemo.location
  resource_group_name = azurerm_resource_group.kubenetdemo.name
  routes = [{
    name                   = "azurekubernetdemo-rt"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.10.1"
  }]
  tags = local.tags
}

# Create the managed identity separately
resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "aks-kubenet-demo-identity"
  resource_group_name = azurerm_resource_group.kubenetdemo.name
  location            = azurerm_resource_group.kubenetdemo.location
}

# Assign Network Contributor role to the identity
resource "azurerm_role_assignment" "aks_vnet_rbac" {
  scope                = azurerm_virtual_network.kubenetdemo.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

# Assign Network Contributor role to the identity
resource "azurerm_role_assignment" "aks_rt_rbac" {
  scope                = module.aks_route_table.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}


# Associate the route table with the node subnet
resource "azurerm_subnet_route_table_association" "subnet_route_table" {
  subnet_id      = azurerm_subnet.kubenetdemo-node.id
  route_table_id = module.aks_route_table.id
}

module "aks" {
  source     = "../../"
  depends_on = [azurerm_role_assignment.aks_vnet_rbac]

  # Pass the identity to the module
  user_assigned_identity_id = azurerm_user_assigned_identity.aks_identity.id

  location = azurerm_resource_group.kubenetdemo.location

  # Required networking variables
  dns_service_ip = "10.0.0.10"
  service_cidr   = "10.0.0.0/16"

  node_subnet     = azurerm_subnet.kubenetdemo-node.id
  endpoint_subnet = azurerm_subnet.kubenetdemo-endpoint.id

  # AKS Configuration
  kubernetes_cluster_name  = "kubenetdemo-aks"
  resource_group_name      = azurerm_resource_group.kubenetdemo.name
  dns_prefix               = "kubenetdemo"
  node_resource_group_name = "akskubenetdemo-nodes"

  kubernetes_version      = "1.28.9"
  network_plugin          = "kubenet"
  network_policy          = "calico"
  private_cluster_enabled = true
  outbound_type           = "userDefinedRouting"

  # Optional features
  workload_identity_enabled = true
  oidc_issuer_enabled       = true
  azure_policy_enabled      = true

  # System node pool configuration
  system_node_name    = "system"
  system_node_vm_size = "Standard_B2s"
  system_node_count   = 2

  # Required for RBAC
  aks_administrators = [""] # Replace with actual admin group ID

  tags = local.tags
}
