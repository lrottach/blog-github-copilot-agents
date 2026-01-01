# -----------------------------------------------------------------------------
# App Service Module - Input Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "The name of the App Service"
  type        = string
}

variable "location" {
  description = "The Azure region where the App Service will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "service_plan_id" {
  description = "The ID of the App Service Plan"
  type        = string
}

# -----------------------------------------------------------------------------
# Security Settings
# -----------------------------------------------------------------------------

variable "https_only" {
  description = "Force HTTPS for all connections"
  type        = bool
  default     = true
}

variable "ftps_state" {
  description = "FTPS state for the App Service"
  type        = string
  default     = "Disabled"

  validation {
    condition     = contains(["AllAllowed", "FtpsOnly", "Disabled"], var.ftps_state)
    error_message = "FTPS state must be AllAllowed, FtpsOnly, or Disabled."
  }
}

variable "minimum_tls_version" {
  description = "Minimum TLS version for the App Service"
  type        = string
  default     = "1.2"

  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "Minimum TLS version must be 1.0, 1.1, or 1.2."
  }
}

# -----------------------------------------------------------------------------
# Site Configuration
# -----------------------------------------------------------------------------

variable "always_on" {
  description = "Keep the app always loaded (requires Basic tier or higher)"
  type        = bool
  default     = true
}

variable "http2_enabled" {
  description = "Enable HTTP/2 protocol"
  type        = bool
  default     = true
}

variable "vnet_route_all_enabled" {
  description = "Route all outbound traffic through VNet"
  type        = bool
  default     = false
}

variable "health_check_path" {
  description = "Path to the health check endpoint"
  type        = string
  default     = null
}

variable "health_check_eviction_time_in_min" {
  description = "Time in minutes to evict unhealthy instances"
  type        = number
  default     = 10
}

# -----------------------------------------------------------------------------
# Application Stack
# -----------------------------------------------------------------------------

variable "application_stack" {
  description = "The application stack configuration"
  type = object({
    dotnet_version = optional(string)
    node_version   = optional(string)
    python_version = optional(string)
    java_version   = optional(string)
  })
  default = {
    dotnet_version = "8.0"
    node_version   = null
    python_version = null
    java_version   = null
  }
}

# -----------------------------------------------------------------------------
# App Settings and Connection Strings
# -----------------------------------------------------------------------------

variable "app_settings" {
  description = "Application settings (environment variables)"
  type        = map(string)
  default     = {}
}

variable "connection_strings" {
  description = "Connection strings for the App Service"
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  default = []

  # Note: Connection string types: SQLServer, SQLAzure, MySQL, PostgreSQL,
  # Custom, NotificationHub, ServiceBus, EventHub, APIHub, DocDb, RedisCache
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to apply to the App Service"
  type        = map(string)
  default     = {}
}
