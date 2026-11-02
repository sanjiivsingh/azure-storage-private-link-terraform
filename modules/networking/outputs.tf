output "vnet_id" { value = azurerm_virtual_network.this.id }
output "private_endpoint_subnet_id" { value = azurerm_subnet.private_endpoints.id }
