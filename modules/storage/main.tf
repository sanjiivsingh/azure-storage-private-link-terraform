resource "random_string" "suffix" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "azurerm_storage_account" "this" {
  name                            = substr("${var.name_prefix}${random_string.suffix.result}", 0, 24)
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = var.account_replication
  account_kind                    = "StorageV2"
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true

  blob_properties {
    versioning_enabled = true
    delete_retention_policy { days = 7 }
    container_delete_retention_policy { days = 7 }
  }

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  sas_policy {
    expiration_period = "90.00:00:00"
    expiration_action = "Log"
  }

  tags = var.tags
}
