variable "subscription_id" {
  description = "Azure subscription ID (optional when authenticated via Azure CLI or ambient environment)."
  type        = string
  default     = null
  sensitive   = true
}
variable "location" {
  description = "Azure region."
  type        = string
  default     = "Central India"
}
variable "resource_group_name" {
  description = "Resource group name."
  type        = string
  default     = "rg-storage-private-link-dev"
}
variable "name_prefix" {
  description = "3-10 lowercase alphanumeric characters."
  type        = string
  default     = "stpldev"
  validation {
    condition     = can(regex("^[a-z0-9]{3,10}$", var.name_prefix))
    error_message = "Use 3-10 lowercase letters or digits."
  }
}
variable "vnet_address_space" {
  description = "Spoke VNet address space."
  type        = list(string)
  default     = ["10.40.0.0/16"]
}
variable "pe_subnet_prefixes" {
  description = "Private Endpoint subnet prefixes."
  type        = list(string)
  default     = ["10.40.10.0/24"]
}
variable "storage_subresources" {
  description = "Storage Private Link subresources."
  type        = set(string)
  default     = ["blob", "file", "queue", "table"]
  validation {
    condition     = length(var.storage_subresources) > 0 && length(setsubtract(var.storage_subresources, toset(["blob", "file", "queue", "table"]))) == 0
    error_message = "Allowed values: blob, file, queue, table."
  }
}
variable "account_replication" {
  description = "Storage replication SKU."
  type        = string
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "GZRS", "RAGRS", "RAGZRS"], var.account_replication)
    error_message = "Unsupported Storage replication SKU."
  }
}
variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default = {
    environment = "dev"
    managed_by  = "terraform"
    project     = "azure-storage-private-link"
  }
}
