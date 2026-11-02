output "resource_group_name" { value = azurerm_resource_group.this.name }
output "storage_account_name" { value = module.storage.storage_account_name }
output "storage_blob_endpoint" { value = module.storage.primary_blob_endpoint }
output "private_endpoint_ids" { value = module.private_endpoint.private_endpoint_ids }
output "private_endpoint_private_ips" { value = module.private_endpoint.private_endpoint_private_ips }
output "private_dns_zone_ids" { value = module.private_endpoint.private_dns_zone_ids }
