# -----------------------------------------------------------------------------
# Storage Account Module - Outputs
# -----------------------------------------------------------------------------

output "id" {
  description = "The ID of the Storage Account"
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "The name of the Storage Account"
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint URL"
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_access_key" {
  description = "The primary access key for the Storage Account"
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "The primary connection string for the Storage Account"
  value       = azurerm_storage_account.this.primary_connection_string
  sensitive   = true
}

output "identity_principal_id" {
  description = "The principal ID of the system-assigned managed identity"
  value       = azurerm_storage_account.this.identity[0].principal_id
}

output "identity_tenant_id" {
  description = "The tenant ID of the system-assigned managed identity"
  value       = azurerm_storage_account.this.identity[0].tenant_id
}

output "container_ids" {
  description = "A map of container names to their IDs"
  value       = { for k, v in azurerm_storage_container.this : k => v.id }
}
