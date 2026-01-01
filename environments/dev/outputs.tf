# -----------------------------------------------------------------------------
# Dev Environment - Outputs
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Resource Group Outputs
# -----------------------------------------------------------------------------

output "resource_group_ids" {
  description = "Map of resource group names to their IDs"
  value = {
    app      = module.rg_app.id
    network  = module.rg_network.id
    database = module.rg_database.id
    storage  = module.rg_storage.id
    security = module.rg_security.id
  }
}

# -----------------------------------------------------------------------------
# Network Outputs
# -----------------------------------------------------------------------------

output "virtual_network_id" {
  description = "The ID of the Virtual Network"
  value       = module.virtual_network.id
}

output "virtual_network_name" {
  description = "The name of the Virtual Network"
  value       = module.virtual_network.name
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = module.virtual_network.subnet_ids
}

# -----------------------------------------------------------------------------
# App Service Outputs
# -----------------------------------------------------------------------------

output "app_service_api_hostname" {
  description = "The default hostname of the API App Service"
  value       = module.app_service_api.default_hostname
}

output "app_service_api_url" {
  description = "The URL of the API App Service"
  value       = "https://${module.app_service_api.default_hostname}"
}

output "app_service_web_hostname" {
  description = "The default hostname of the WEB App Service"
  value       = module.app_service_web.default_hostname
}

output "app_service_web_url" {
  description = "The URL of the WEB App Service"
  value       = "https://${module.app_service_web.default_hostname}"
}

output "app_service_api_identity_principal_id" {
  description = "The principal ID of the API App Service managed identity"
  value       = module.app_service_api.identity_principal_id
}

output "app_service_web_identity_principal_id" {
  description = "The principal ID of the WEB App Service managed identity"
  value       = module.app_service_web.identity_principal_id
}

# -----------------------------------------------------------------------------
# SQL Database Outputs
# -----------------------------------------------------------------------------

output "sql_server_fqdn" {
  description = "The fully qualified domain name of the SQL Server"
  value       = module.sql_database.server_fqdn
}

output "sql_database_name" {
  description = "The name of the SQL Database"
  value       = module.sql_database.database_name
}

# -----------------------------------------------------------------------------
# Storage Account Outputs
# -----------------------------------------------------------------------------

output "storage_account_name" {
  description = "The name of the Storage Account"
  value       = module.storage_account.name
}

output "storage_account_primary_blob_endpoint" {
  description = "The primary blob endpoint of the Storage Account"
  value       = module.storage_account.primary_blob_endpoint
}

# -----------------------------------------------------------------------------
# Key Vault Outputs
# -----------------------------------------------------------------------------

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = module.key_vault.name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = module.key_vault.uri
}
