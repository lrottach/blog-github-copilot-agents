# -----------------------------------------------------------------------------
# App Service Plan Module - Outputs
# -----------------------------------------------------------------------------

output "id" {
  description = "The ID of the App Service Plan"
  value       = azurerm_service_plan.this.id
}

output "name" {
  description = "The name of the App Service Plan"
  value       = azurerm_service_plan.this.name
}

output "os_type" {
  description = "The OS type of the App Service Plan"
  value       = azurerm_service_plan.this.os_type
}

output "sku_name" {
  description = "The SKU of the App Service Plan"
  value       = azurerm_service_plan.this.sku_name
}

output "kind" {
  description = "The kind of the App Service Plan"
  value       = azurerm_service_plan.this.kind
}
