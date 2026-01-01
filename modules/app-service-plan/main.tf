# -----------------------------------------------------------------------------
# Azure App Service Plan Module
# -----------------------------------------------------------------------------
# This module creates an Azure App Service Plan (hosting environment for
# App Services). Each plan defines the compute resources and pricing tier.
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
# App Service Plan
# -----------------------------------------------------------------------------

resource "azurerm_service_plan" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = var.os_type
  sku_name            = var.sku_name

  # Optional scaling configuration
  worker_count           = var.worker_count
  zone_balancing_enabled = var.zone_balancing_enabled

  tags = var.tags
}
