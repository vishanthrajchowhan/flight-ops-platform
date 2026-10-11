# Databricks workspace (Premium tier is required for Unity Catalog)
resource "azurerm_databricks_workspace" "main" {
  name                        = "dbw-${var.project}-${var.environment}"
  resource_group_name         = azurerm_resource_group.main.name
  location                    = azurerm_resource_group.main.location
  sku                         = "premium"
  managed_resource_group_name = "rg-${var.project}-${var.environment}-dbw-managed"

  tags = local.tags
}

# Managed identity that Databricks uses to reach the data lake (no keys)
resource "azurerm_databricks_access_connector" "main" {
  name                = "dbac-${var.project}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

# Allow that identity to read and write the data lake
resource "azurerm_role_assignment" "dbac_storage" {
  scope                = azurerm_storage_account.datalake.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.main.identity[0].principal_id
}
