locals {
  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Storage account names must be globally unique, so add a random suffix
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project}-${var.environment}"
  location = var.location
  tags     = local.tags
}

resource "azurerm_storage_account" "datalake" {
  name                            = "st${var.project}${var.environment}${random_string.suffix.result}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  is_hns_enabled                  = true # this is what makes it ADLS Gen2
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = local.tags
}

resource "azurerm_storage_container" "layers" {
  for_each              = toset(["bronze", "silver", "gold"])
  name                  = each.key
  storage_account_id    = azurerm_storage_account.datalake.id
  container_access_type = "private"
}
