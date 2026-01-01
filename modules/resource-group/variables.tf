# -----------------------------------------------------------------------------
# Resource Group Module - Input Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "The name of the resource group"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]+$", var.name))
    error_message = "Resource group name can only contain alphanumeric characters, periods, underscores, and hyphens."
  }
}

variable "location" {
  description = "The Azure region where the resource group will be created"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to the resource group"
  type        = map(string)
  default     = {}
}
