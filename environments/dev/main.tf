resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "networking" {
  source              = "../../modules/networking"
  name_prefix         = var.name_prefix
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  vnet_address_space  = var.vnet_address_space
  pe_subnet_prefixes  = var.pe_subnet_prefixes
  tags                = var.tags
}

module "storage" {
  source              = "../../modules/storage"
  name_prefix         = var.name_prefix
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  account_replication = var.account_replication
  tags                = var.tags
}

module "private_endpoint" {
  source                    = "../../modules/private-endpoint"
  name_prefix               = var.name_prefix
  location                  = azurerm_resource_group.this.location
  resource_group_name       = azurerm_resource_group.this.name
  subnet_id                 = module.networking.private_endpoint_subnet_id
  private_connection_target = module.storage.storage_account_id
  private_dns_zone_vnet_id  = module.networking.vnet_id
  subresource_names         = var.storage_subresources
  tags                      = var.tags
}
