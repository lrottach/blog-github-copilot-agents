# -----------------------------------------------------------------------------
# App Service Module - Outputs
# -----------------------------------------------------------------------------

output "id" {
  description = "The ID of the App Service"
  value       = azurerm_linux_web_app.this.id
}

output "name" {
  description = "The name of the App Service"
  value       = azurerm_linux_web_app.this.name
}

output "default_hostname" {
  description = "The default hostname of the App Service"
  value       = azurerm_linux_web_app.this.default_hostname
}

output "outbound_ip_addresses" {
  description = "The outbound IP addresses of the App Service"
  value       = azurerm_linux_web_app.this.outbound_ip_addresses
}

output "possible_outbound_ip_addresses" {
  description = "The possible outbound IP addresses of the App Service"
  value       = azurerm_linux_web_app.this.possible_outbound_ip_addresses
}

output "identity_principal_id" {
  description = "The principal ID of the system-assigned managed identity"
  value       = azurerm_linux_web_app.this.identity[0].principal_id
}

output "identity_tenant_id" {
  description = "The tenant ID of the system-assigned managed identity"
  value       = azurerm_linux_web_app.this.identity[0].tenant_id
}
