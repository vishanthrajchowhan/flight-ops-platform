# Azure Data Factory with a system-assigned managed identity
resource "azurerm_data_factory" "main" {
  name                = "adf-${var.project}-${var.environment}-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

# Let ADF's identity write raw files into the data lake (no keys)
resource "azurerm_role_assignment" "adf_storage" {
  scope                = azurerm_storage_account.datalake.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_factory.main.identity[0].principal_id
}

# Linked service: BTS public download site (anonymous HTTP)
resource "azurerm_data_factory_linked_service_web" "bts" {
  name                = "ls_http_bts"
  data_factory_id     = azurerm_data_factory.main.id
  authentication_type = "Anonymous"
  url                 = "https://transtats.bts.gov/PREZIP/"
}

# Linked service: our ADLS Gen2 data lake via managed identity
resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "datalake" {
  name                 = "ls_adls_datalake"
  data_factory_id      = azurerm_data_factory.main.id
  url                  = azurerm_storage_account.datalake.primary_dfs_endpoint
  use_managed_identity = true
}
