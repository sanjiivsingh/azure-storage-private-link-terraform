output "private_endpoint_ids" {
  value = { for k, pe in azurerm_private_endpoint.storage : k => pe.id }
}
output "private_endpoint_private_ips" {
  value = { for k, pe in azurerm_private_endpoint.storage : k => pe.private_service_connection[0].private_ip_address }
}
output "private_dns_zone_ids" {
  value = { for k, zone in azurerm_private_dns_zone.storage : k => zone.id }
}
