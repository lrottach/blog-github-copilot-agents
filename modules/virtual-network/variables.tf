# -----------------------------------------------------------------------------
# Virtual Network Module - Input Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "The name of the Virtual Network"
  type        = string
}

variable "location" {
  description = "The Azure region where the Virtual Network will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "address_space" {
  description = "The address space(s) for the Virtual Network in CIDR notation"
  type        = list(string)
  default     = ["10.0.0.0/16"]

  validation {
    condition     = length(var.address_space) > 0
    error_message = "At least one address space must be provided."
  }
}

variable "dns_servers" {
  description = "Custom DNS servers for the Virtual Network (empty list uses Azure DNS)"
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = "A map of subnets to create within the Virtual Network"
  type = map(object({
    name              = string
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
    delegation = optional(object({
      name         = string
      service_name = string
      actions      = list(string)
    }))
  }))
  default = {}

  # Example subnet configuration:
  # subnets = {
  #   "app" = {
  #     name             = "snet-app"
  #     address_prefixes = ["10.0.1.0/24"]
  #     service_endpoints = ["Microsoft.Sql", "Microsoft.Storage"]
  #     delegation = {
  #       name         = "appservice"
  #       service_name = "Microsoft.Web/serverFarms"
  #       actions      = ["Microsoft.Network/virtualNetworks/subnets/action"]
  #     }
  #   }
  # }
}

variable "tags" {
  description = "A map of tags to apply to the Virtual Network"
  type        = map(string)
  default     = {}
}
