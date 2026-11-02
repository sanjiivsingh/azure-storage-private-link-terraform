locals {
  storage_services = {
    blob  = { dns_zone_name = "privatelink.blob.core.windows.net" }
    file  = { dns_zone_name = "privatelink.file.core.windows.net" }
    queue = { dns_zone_name = "privatelink.queue.core.windows.net" }
    table = { dns_zone_name = "privatelink.table.core.windows.net" }
  }
  enabled_services = {
    for service in var.subresource_names : service => local.storage_services[service]
  }
}
