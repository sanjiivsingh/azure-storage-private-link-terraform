variable "name_prefix" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "subnet_id" { type = string }
variable "private_connection_target" { type = string }
variable "private_dns_zone_vnet_id" { type = string }
variable "subresource_names" {
  type = set(string)
  validation {
    condition     = length(var.subresource_names) > 0 && length(setsubtract(var.subresource_names, toset(["blob", "file", "queue", "table"]))) == 0
    error_message = "Allowed values: blob, file, queue, table."
  }
}
variable "tags" {
  type    = map(string)
  default = {}
}
