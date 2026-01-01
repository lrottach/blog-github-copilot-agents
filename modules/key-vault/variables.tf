# -----------------------------------------------------------------------------
# Key Vault Module - Input Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "The name of the Key Vault (3-24 chars, globally unique)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.name))
    error_message = "Key Vault name must be 3-24 characters, start with a letter, end with a letter or number, and contain only letters, numbers, and hyphens."
  }
}

variable "location" {
  description = "The Azure region where the Key Vault will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "sku_name" {
  description = "The SKU of the Key Vault"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "SKU must be standard or premium."
  }
}

# -----------------------------------------------------------------------------
# Soft Delete and Purge Protection
# -----------------------------------------------------------------------------

variable "soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted secrets (7-90)"
  type        = number
  default     = 7

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Soft delete retention days must be between 7 and 90."
  }
}

variable "purge_protection_enabled" {
  description = "Enable purge protection (prevents permanent deletion during retention period)"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Access Configuration
# -----------------------------------------------------------------------------

variable "enable_rbac_authorization" {
  description = "Use Azure RBAC for data plane authorization instead of access policies"
  type        = bool
  default     = true
}

variable "enabled_for_disk_encryption" {
  description = "Allow Azure Disk Encryption to retrieve secrets"
  type        = bool
  default     = false
}

variable "enabled_for_deployment" {
  description = "Allow Virtual Machines to retrieve certificates"
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Allow Azure Resource Manager to retrieve secrets"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------

variable "network_acls" {
  description = "Network ACL configuration for the Key Vault"
  type = object({
    default_action             = string
    bypass                     = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  default = {
    default_action             = "Allow"
    bypass                     = "AzureServices"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }

  # default_action: "Allow" or "Deny"
  # bypass: "AzureServices" or "None"
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to apply to the Key Vault"
  type        = map(string)
  default     = {}
}
