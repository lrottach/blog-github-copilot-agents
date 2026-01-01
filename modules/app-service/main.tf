# -----------------------------------------------------------------------------
# Azure App Service Module
# -----------------------------------------------------------------------------
# This module creates an Azure Linux Web App with system-assigned managed
# identity. Supports configurable application stacks, app settings, and
# connection strings.
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
# Linux Web App
# -----------------------------------------------------------------------------

resource "azurerm_linux_web_app" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = var.service_plan_id

  # Security settings
  https_only = var.https_only

  # Site configuration
  site_config {
    always_on                         = var.always_on
    ftps_state                        = var.ftps_state
    http2_enabled                     = var.http2_enabled
    minimum_tls_version               = var.minimum_tls_version
    vnet_route_all_enabled            = var.vnet_route_all_enabled
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = var.health_check_path != null ? var.health_check_eviction_time_in_min : null

    # Application stack configuration
    application_stack {
      dotnet_version = var.application_stack.dotnet_version
      node_version   = var.application_stack.node_version
      python_version = var.application_stack.python_version
      java_version   = var.application_stack.java_version
    }
  }

  # App settings (environment variables)
  app_settings = var.app_settings

  # Connection strings
  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  # System-assigned managed identity
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
