output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "datalake_name" {
  value = azurerm_storage_account.datalake.name
}

output "datalake_dfs_endpoint" {
  value = azurerm_storage_account.datalake.primary_dfs_endpoint
}

output "key_vault_name" {
  value = azurerm_key_vault.main.name
}
