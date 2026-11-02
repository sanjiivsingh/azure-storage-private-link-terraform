resource "azurerm_private_dns_zone" "storage" {
  for_each            = local.enabled_services
  name                = each.value.dns_zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage" {
  for_each              = local.enabled_services
  name                  = "link-${var.name_prefix}-${each.key}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.storage[each.key].name
  virtual_network_id    = var.private_dns_zone_vnet_id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_endpoint" "storage" {
  for_each            = local.enabled_services
  name                = "pe-${var.name_prefix}-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-${var.name_prefix}-${each.key}"
    private_connection_resource_id = var.private_connection_target
    subresource_names              = [each.key]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage[each.key].id]
  }
  tags = var.tags
}
