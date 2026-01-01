# -----------------------------------------------------------------------------
# Azure Resource Group Module
# -----------------------------------------------------------------------------
# This module creates an Azure Resource Group with consistent tagging.
# Resource groups are logical containers for Azure resources.
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
# Resource Group
# -----------------------------------------------------------------------------

resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = var.tags
}
