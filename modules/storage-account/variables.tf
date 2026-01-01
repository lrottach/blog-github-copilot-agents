# -----------------------------------------------------------------------------
# Storage Account Module - Input Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "The name of the Storage Account (3-24 chars, lowercase alphanumeric only)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account name must be 3-24 characters, lowercase letters and numbers only."
  }
}

variable "location" {
  description = "The Azure region where the Storage Account will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

# -----------------------------------------------------------------------------
# Account Configuration
# -----------------------------------------------------------------------------

variable "account_tier" {
  description = "The tier of the storage account"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be Standard or Premium."
  }
}

variable "account_replication_type" {
  description = "The replication type of the storage account"
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Replication type must be LRS, GRS, RAGRS, ZRS, GZRS, or RAGZRS."
  }
}

variable "account_kind" {
  description = "The kind of storage account"
  type        = string
  default     = "StorageV2"

  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.account_kind)
    error_message = "Account kind must be BlobStorage, BlockBlobStorage, FileStorage, Storage, or StorageV2."
  }
}

# -----------------------------------------------------------------------------
# Security Settings
# -----------------------------------------------------------------------------

variable "min_tls_version" {
  description = "Minimum TLS version for the storage account"
  type        = string
  default     = "TLS1_2"

  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.min_tls_version)
    error_message = "Minimum TLS version must be TLS1_0, TLS1_1, or TLS1_2."
  }
}

variable "allow_public_blob_access" {
  description = "Allow public access to blobs"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Blob Configuration
# -----------------------------------------------------------------------------

variable "enable_versioning" {
  description = "Enable blob versioning"
  type        = bool
  default     = false
}

variable "enable_change_feed" {
  description = "Enable blob change feed"
  type        = bool
  default     = false
}

variable "enable_last_access_time_tracking" {
  description = "Enable last access time tracking"
  type        = bool
  default     = false
}

variable "blob_soft_delete_days" {
  description = "Number of days to retain deleted blobs (0 to disable)"
  type        = number
  default     = 7

  validation {
    condition     = var.blob_soft_delete_days >= 0 && var.blob_soft_delete_days <= 365
    error_message = "Blob soft delete days must be between 0 and 365."
  }
}

variable "container_soft_delete_days" {
  description = "Number of days to retain deleted containers (0 to disable)"
  type        = number
  default     = 7

  validation {
    condition     = var.container_soft_delete_days >= 0 && var.container_soft_delete_days <= 365
    error_message = "Container soft delete days must be between 0 and 365."
  }
}

# -----------------------------------------------------------------------------
# Containers
# -----------------------------------------------------------------------------

variable "containers" {
  description = "A map of containers to create"
  type = map(object({
    access_type = string
  }))
  default = {}

  # access_type can be: "blob", "container", or "private"
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to apply to the Storage Account"
  type        = map(string)
  default     = {}
}
