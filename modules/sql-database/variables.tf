# -----------------------------------------------------------------------------
# SQL Database Module - Input Variables
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Server Configuration
# -----------------------------------------------------------------------------

variable "server_name" {
  description = "The name of the SQL Server (globally unique)"
  type        = string
}

variable "location" {
  description = "The Azure region where the SQL Server will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "sql_version" {
  description = "The version of the SQL Server"
  type        = string
  default     = "12.0"

  validation {
    condition     = contains(["2.0", "12.0"], var.sql_version)
    error_message = "SQL version must be 2.0 or 12.0."
  }
}

variable "administrator_login" {
  description = "The administrator login for the SQL Server"
  type        = string
}

variable "administrator_login_password" {
  description = "The administrator password for the SQL Server"
  type        = string
  sensitive   = true
}

variable "minimum_tls_version" {
  description = "Minimum TLS version for the SQL Server"
  type        = string
  default     = "1.2"

  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "Minimum TLS version must be 1.0, 1.1, or 1.2."
  }
}

variable "azuread_administrator" {
  description = "Azure AD administrator configuration"
  type = object({
    login_username = string
    object_id      = string
  })
  default = null
}

# -----------------------------------------------------------------------------
# Database Configuration
# -----------------------------------------------------------------------------

variable "database_name" {
  description = "The name of the SQL Database"
  type        = string
}

variable "collation" {
  description = "The collation of the SQL Database"
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "license_type" {
  description = "License type for the SQL Database"
  type        = string
  default     = "LicenseIncluded"

  validation {
    condition     = contains(["LicenseIncluded", "BasePrice"], var.license_type)
    error_message = "License type must be LicenseIncluded or BasePrice."
  }
}

variable "sku_name" {
  description = "The SKU name for the SQL Database (e.g., S0, S1, P1)"
  type        = string
  default     = "S0"
}

variable "max_size_gb" {
  description = "The maximum size of the database in gigabytes"
  type        = number
  default     = 2
}

# -----------------------------------------------------------------------------
# Backup Configuration
# -----------------------------------------------------------------------------

variable "short_term_retention_days" {
  description = "Point-in-time restore retention in days (1-35)"
  type        = number
  default     = 7

  validation {
    condition     = var.short_term_retention_days >= 1 && var.short_term_retention_days <= 35
    error_message = "Short term retention days must be between 1 and 35."
  }
}

variable "backup_interval_in_hours" {
  description = "Backup interval in hours (12 or 24)"
  type        = number
  default     = 12

  validation {
    condition     = contains([12, 24], var.backup_interval_in_hours)
    error_message = "Backup interval must be 12 or 24 hours."
  }
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------

variable "allow_azure_services" {
  description = "Allow Azure services to access the SQL Server"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to apply to the SQL resources"
  type        = map(string)
  default     = {}
}
