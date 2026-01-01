# -----------------------------------------------------------------------------
# Azure SQL Database Module
# -----------------------------------------------------------------------------
# This module creates an Azure SQL Server and Database with Azure AD
# authentication support and system-assigned managed identity.
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}

# -----------------------------------------------------------------------------
# SQL Server
# -----------------------------------------------------------------------------

resource "azurerm_mssql_server" "this" {
  name                         = var.server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.sql_version
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password
  minimum_tls_version          = var.minimum_tls_version

  # Azure AD administrator (recommended for production)
  dynamic "azuread_administrator" {
    for_each = var.azuread_administrator != null ? [var.azuread_administrator] : []
    content {
      login_username = azuread_administrator.value.login_username
      object_id      = azuread_administrator.value.object_id
    }
  }

  # System-assigned managed identity
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# SQL Database
# -----------------------------------------------------------------------------

resource "azurerm_mssql_database" "this" {
  name         = var.database_name
  server_id    = azurerm_mssql_server.this.id
  collation    = var.collation
  license_type = var.license_type
  sku_name     = var.sku_name
  max_size_gb  = var.max_size_gb

  # Backup configuration
  short_term_retention_policy {
    retention_days           = var.short_term_retention_days
    backup_interval_in_hours = var.backup_interval_in_hours
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Firewall Rule - Allow Azure Services
# -----------------------------------------------------------------------------

resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  count = var.allow_azure_services ? 1 : 0

  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
