# -----------------------------------------------------------------------------
# Dev Environment - Local Values
# -----------------------------------------------------------------------------

locals {
  # ---------------------------------------------------------------------------
  # Common Tags
  # ---------------------------------------------------------------------------
  common_tags = merge(
    {
      Environment = var.environment
      Project     = var.workload_name
      ManagedBy   = "Terraform"
      Repository  = "blog-github-copilot-agents"
    },
    var.tags
  )

  # ---------------------------------------------------------------------------
  # Naming Convention
  # ---------------------------------------------------------------------------
  # Pattern: {resource-type}-{workload}-{environment}-{location}-{instance}

  name_suffix = "${var.workload_name}-${var.environment}-${var.location}"

  # Resource Group Names
  rg_names = {
    app      = "rg-app-${local.name_suffix}-001"
    network  = "rg-network-${local.name_suffix}-001"
    database = "rg-database-${local.name_suffix}-001"
    storage  = "rg-storage-${local.name_suffix}-001"
    security = "rg-security-${local.name_suffix}-001"
  }

  # ---------------------------------------------------------------------------
  # Network Configuration
  # ---------------------------------------------------------------------------
  subnets = {
    app = {
      name             = "snet-app-${local.name_suffix}-001"
      address_prefixes = var.subnet_app_prefix
      service_endpoints = [
        "Microsoft.Sql",
        "Microsoft.Storage",
        "Microsoft.KeyVault"
      ]
      # Delegation for future App Service VNet integration
      delegation = {
        name         = "appservice-delegation"
        service_name = "Microsoft.Web/serverFarms"
        actions      = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
    data = {
      name              = "snet-data-${local.name_suffix}-001"
      address_prefixes  = var.subnet_data_prefix
      service_endpoints = ["Microsoft.Sql", "Microsoft.Storage"]
      delegation        = null
    }
  }

  # ---------------------------------------------------------------------------
  # Resource Names
  # ---------------------------------------------------------------------------

  # Virtual Network
  vnet_name = "vnet-${local.name_suffix}-001"

  # App Service Plans
  asp_api_name = "asp-api-${local.name_suffix}-001"
  asp_web_name = "asp-web-${local.name_suffix}-001"

  # App Services
  app_api_name = "app-api-${local.name_suffix}-001"
  app_web_name = "app-web-${local.name_suffix}-001"

  # SQL Database
  sql_server_name   = "sql-${local.name_suffix}-001"
  sql_database_name = "sqldb-app-${local.name_suffix}-001"

  # Storage Account (no hyphens, lowercase, max 24 chars)
  # Using abbreviated format: st{workload}{env}{region}{instance}
  region_short = {
    "westeurope"  = "we"
    "northeurope" = "ne"
    "eastus"      = "eus"
    "eastus2"     = "eus2"
  }
  storage_account_name = "st${var.workload_name}${var.environment}${lookup(local.region_short, var.location, "xx")}001"

  # Key Vault (max 24 chars)
  key_vault_name = "kv-${var.workload_name}-${var.environment}-${lookup(local.region_short, var.location, "xx")}-001"
}
