# -----------------------------------------------------------------------------
# App Service Plan Module - Input Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "The name of the App Service Plan"
  type        = string
}

variable "location" {
  description = "The Azure region where the App Service Plan will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "os_type" {
  description = "The operating system type for the App Service Plan"
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows", "WindowsContainer"], var.os_type)
    error_message = "OS type must be Linux, Windows, or WindowsContainer."
  }
}

variable "sku_name" {
  description = "The SKU name for the App Service Plan (e.g., F1, B1, S1, P1v3)"
  type        = string
  default     = "S1"

  validation {
    condition = contains([
      "F1", "D1", "B1", "B2", "B3",
      "S1", "S2", "S3",
      "P1v2", "P2v2", "P3v2",
      "P1v3", "P2v3", "P3v3",
      "P0v3", "P1mv3", "P2mv3", "P3mv3", "P4mv3", "P5mv3",
      "I1", "I2", "I3",
      "I1v2", "I2v2", "I3v2",
      "I4v2", "I5v2", "I6v2",
      "WS1", "WS2", "WS3",
      "Y1"
    ], var.sku_name)
    error_message = "SKU name must be a valid App Service Plan SKU."
  }
}

variable "worker_count" {
  description = "The number of workers (instances) to allocate"
  type        = number
  default     = 1

  validation {
    condition     = var.worker_count >= 1
    error_message = "Worker count must be at least 1."
  }
}

variable "zone_balancing_enabled" {
  description = "Enable zone balancing for the App Service Plan (requires Premium v2/v3 SKU)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to apply to the App Service Plan"
  type        = map(string)
  default     = {}
}
