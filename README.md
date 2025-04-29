# terraform-azure-mcaf-azure-kubernetes-service
Terraform module that will deploy some infra that could be used for Azure Devops icm Terraform

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4, < 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_role_assignment.cmk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.extra](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_customer_managed_key.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_customer_managed_key) | resource |
| [azurerm_storage_account_network_rules.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules) | resource |
| [azurerm_storage_container.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Location of the Storage account | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Storage Account | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group to Create the Storage account in | `string` | n/a | yes |
| <a name="input_access_tier"></a> [access\_tier](#input\_access\_tier) | The access tier for the storage account. Valid options are Hot and Cool. Defaults to Hot. | `string` | `"Hot"` | no |
| <a name="input_account_kind"></a> [account\_kind](#input\_account\_kind) | The Kind of account to create. Valid options are Storage, StorageV2, BlobStorage, FileStorage, BlockBlobStorage, and StorageV2. Defaults to StorageV2. | `string` | `"StorageV2"` | no |
| <a name="input_account_replication_type"></a> [account\_replication\_type](#input\_account\_replication\_type) | The type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS, and RA\_GZRS. Defaults to GRS. | `string` | `"ZRS"` | no |
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | The Tier to use for this storage account. Valid options are Standard and Premium. Defaults to Standard. | `string` | `"Standard"` | no |
| <a name="input_allow_nested_items_to_be_public"></a> [allow\_nested\_items\_to\_be\_public](#input\_allow\_nested\_items\_to\_be\_public) | Allow or disallow nested items to be public. Defaults to false. | `bool` | `false` | no |
| <a name="input_blob_delete_retention_days"></a> [blob\_delete\_retention\_days](#input\_blob\_delete\_retention\_days) | The number of days to retain deleted blobs for. Defaults to 90. | `number` | `90` | no |
| <a name="input_change_feed_enabled"></a> [change\_feed\_enabled](#input\_change\_feed\_enabled) | Is the blob service properties for change feed events enabled? | `bool` | `true` | no |
| <a name="input_cmk_key_name"></a> [cmk\_key\_name](#input\_cmk\_key\_name) | The name of the Key (within the cmk\_key\_vault) to use as the Customer Managed Key | `string` | `null` | no |
| <a name="input_cmk_key_vault_id"></a> [cmk\_key\_vault\_id](#input\_cmk\_key\_vault\_id) | The ID of the Key Vault to use for the Customer Managed Key | `string` | `null` | no |
| <a name="input_container_delete_retention_days"></a> [container\_delete\_retention\_days](#input\_container\_delete\_retention\_days) | The number of days to retain deleted containers for. Defaults to 90. | `number` | `90` | no |
| <a name="input_contributors"></a> [contributors](#input\_contributors) | List of principal IDs that are allowed to be contributor on this storage account. Defaults to an empty list. | `list(string)` | `[]` | no |
| <a name="input_default_to_oauth_authentication"></a> [default\_to\_oauth\_authentication](#input\_default\_to\_oauth\_authentication) | Allow or disallow defaulting to OAuth authentication for this storage account. Defaults to true. | `bool` | `true` | no |
| <a name="input_enable_cmk_encryption"></a> [enable\_cmk\_encryption](#input\_enable\_cmk\_encryption) | An optional variable to enable supportf for cmk encryption for tables and queues while not setting the cmk encryption | `bool` | `false` | no |
| <a name="input_https_traffic_only_enabled"></a> [https\_traffic\_only\_enabled](#input\_https\_traffic\_only\_enabled) | Allow or disallow only HTTPS traffic to this storage account. Defaults to true. | `bool` | `true` | no |
| <a name="input_immutability_policy"></a> [immutability\_policy](#input\_immutability\_policy) | immutability policy settings for the storage account, defaults to null which does not set any immutability policy | <pre>object({<br>    state                         = optional(string, "Unlocked")<br>    allow_protected_append_writes = optional(bool, true)<br>    period_since_creation_in_days = optional(number, 14)<br>  })</pre> | `null` | no |
| <a name="input_infrastructure_encryption_enabled"></a> [infrastructure\_encryption\_enabled](#input\_infrastructure\_encryption\_enabled) | Allow or disallow infrastructure encryption for this storage account. Defaults to true. | `bool` | `true` | no |
| <a name="input_ip_rules"></a> [ip\_rules](#input\_ip\_rules) | A list of IP addresses that are allowed to access this storage account. Defaults to an empty list. | `list(string)` | `[]` | no |
| <a name="input_min_tls_version"></a> [min\_tls\_version](#input\_min\_tls\_version) | The minimum TLS version to allow for requests to this storage account. Valid options are TLS1\_0, TLS1\_1, and TLS1\_2. Defaults to TLS1\_2. | `string` | `"TLS1_2"` | no |
| <a name="input_network_bypass"></a> [network\_bypass](#input\_network\_bypass) | A list of services that are allowed to bypass the network rules. Defaults to [], could be any of ["Logging", "Metrics", "AzureServices", "None"]. | `list(string)` | <pre>[<br>  "AzureServices"<br>]</pre> | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Allow or disallow public network access to this storage account. Defaults to false. | `bool` | `false` | no |
| <a name="input_sftp_enabled"></a> [sftp\_enabled](#input\_sftp\_enabled) | Allow or disallow SFTP access to this storage account. Defaults to false. | `bool` | `false` | no |
| <a name="input_shared_access_key_enabled"></a> [shared\_access\_key\_enabled](#input\_shared\_access\_key\_enabled) | Allow or disallow shared access keys for this storage account. Defaults to false. | `bool` | `false` | no |
| <a name="input_storage_containers"></a> [storage\_containers](#input\_storage\_containers) | Map of Storage Containers to Create and whether the container should be publically accessible, defaults to private | <pre>map(object({<br>    access_type = optional(string, "private")<br>  }))</pre> | `{}` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet IDs that are allowed to access this storage account. Defaults to an empty list. | `list(string)` | `[]` | no |
| <a name="input_system_assigned_identity_enabled"></a> [system\_assigned\_identity\_enabled](#input\_system\_assigned\_identity\_enabled) | Enable or disable the system-assigned managed identity for this storage account. Defaults to true. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_user_assigned_identities"></a> [user\_assigned\_identities](#input\_user\_assigned\_identities) | List of user assigned identities to assign to the storage account | `list(string)` | `[]` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Is versioning enabled? | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoints"></a> [endpoints](#output\_endpoints) | Endpoint information of the storage account |
| <a name="output_id"></a> [id](#output\_id) | Resource Id of the storage account |
| <a name="output_name"></a> [name](#output\_name) | Name of the storage account |
<!-- END_TF_DOCS -->

## License

**Copyright:** Schuberg Philis

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
