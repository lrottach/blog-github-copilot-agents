# -----------------------------------------------------------------------------
# SQL Database Module - Outputs
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Server Outputs
# -----------------------------------------------------------------------------

output "server_id" {
  description = "The ID of the SQL Server"
  value       = azurerm_mssql_server.this.id
}

output "server_name" {
  description = "The name of the SQL Server"
  value       = azurerm_mssql_server.this.name
}

output "server_fqdn" {
  description = "The fully qualified domain name of the SQL Server"
  value       = azurerm_mssql_server.this.fully_qualified_domain_name
}

output "server_identity_principal_id" {
  description = "The principal ID of the SQL Server managed identity"
  value       = azurerm_mssql_server.this.identity[0].principal_id
}

# -----------------------------------------------------------------------------
# Database Outputs
# -----------------------------------------------------------------------------

output "database_id" {
  description = "The ID of the SQL Database"
  value       = azurerm_mssql_database.this.id
}

output "database_name" {
  description = "The name of the SQL Database"
  value       = azurerm_mssql_database.this.name
}

# -----------------------------------------------------------------------------
# Connection Information
# -----------------------------------------------------------------------------

output "connection_string" {
  description = "ADO.NET connection string template (requires password substitution)"
  value       = "Server=tcp:${azurerm_mssql_server.this.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.this.name};Persist Security Info=False;User ID=${var.administrator_login};Password={your_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
}
