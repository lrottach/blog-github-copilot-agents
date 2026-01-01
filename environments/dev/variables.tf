# -----------------------------------------------------------------------------
# Dev Environment - Input Variables
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Global Configuration
# -----------------------------------------------------------------------------

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "westeurope"
}

variable "workload_name" {
  description = "Name of the workload/application (used in resource naming)"
  type        = string
  default     = "demo"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_app_prefix" {
  description = "Address prefix for the application subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "subnet_data_prefix" {
  description = "Address prefix for the data subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

# -----------------------------------------------------------------------------
# App Service Configuration
# -----------------------------------------------------------------------------

variable "app_service_sku" {
  description = "SKU for App Service Plans"
  type        = string
  default     = "S1"
}

variable "app_service_worker_count" {
  description = "Number of workers for App Service Plans"
  type        = number
  default     = 1
}

variable "dotnet_version" {
  description = ".NET version for App Services"
  type        = string
  default     = "8.0"
}

# -----------------------------------------------------------------------------
# SQL Database Configuration
# -----------------------------------------------------------------------------

variable "sql_administrator_login" {
  description = "Administrator login for SQL Server"
  type        = string
  default     = "sqladmin"
}

variable "sql_administrator_password" {
  description = "Administrator password for SQL Server"
  type        = string
  sensitive   = true
}

variable "sql_sku" {
  description = "SKU for SQL Database"
  type        = string
  default     = "S0"
}

variable "sql_max_size_gb" {
  description = "Maximum size of SQL Database in GB"
  type        = number
  default     = 2
}

# -----------------------------------------------------------------------------
# Storage Configuration
# -----------------------------------------------------------------------------

variable "storage_replication_type" {
  description = "Replication type for Storage Account"
  type        = string
  default     = "LRS"
}
