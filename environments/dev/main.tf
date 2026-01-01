# -----------------------------------------------------------------------------
# Dev Environment - Main Configuration
# -----------------------------------------------------------------------------
# This is the root module that orchestrates all Azure resources for the
# development environment. Resources are deployed in dependency order.
# -----------------------------------------------------------------------------

# =============================================================================
# LEVEL 0: Resource Groups (no dependencies)
# =============================================================================

module "rg_app" {
  source = "../../modules/resource-group"

  name     = local.rg_names.app
  location = var.location
  tags     = local.common_tags
}

module "rg_network" {
  source = "../../modules/resource-group"

  name     = local.rg_names.network
  location = var.location
  tags     = local.common_tags
}

module "rg_database" {
  source = "../../modules/resource-group"

  name     = local.rg_names.database
  location = var.location
  tags     = local.common_tags
}

module "rg_storage" {
  source = "../../modules/resource-group"

  name     = local.rg_names.storage
  location = var.location
  tags     = local.common_tags
}

module "rg_security" {
  source = "../../modules/resource-group"

  name     = local.rg_names.security
  location = var.location
  tags     = local.common_tags
}

# =============================================================================
# LEVEL 1: Virtual Network (depends on: Resource Groups)
# =============================================================================

module "virtual_network" {
  source = "../../modules/virtual-network"

  name                = local.vnet_name
  location            = var.location
  resource_group_name = module.rg_network.name
  address_space       = var.vnet_address_space
  subnets             = local.subnets
  tags                = local.common_tags
}

# =============================================================================
# LEVEL 2: Key Vault (depends on: Resource Groups)
# =============================================================================

module "key_vault" {
  source = "../../modules/key-vault"

  name                       = local.key_vault_name
  location                   = var.location
  resource_group_name        = module.rg_security.name
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false # Set to true in production
  enable_rbac_authorization  = true
  tags                       = local.common_tags

  network_acls = {
    default_action             = "Allow"
    bypass                     = "AzureServices"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
}

# =============================================================================
# LEVEL 3: Data Resources (depend on: Resource Groups)
# =============================================================================

module "sql_database" {
  source = "../../modules/sql-database"

  server_name                  = local.sql_server_name
  database_name                = local.sql_database_name
  location                     = var.location
  resource_group_name          = module.rg_database.name
  administrator_login          = var.sql_administrator_login
  administrator_login_password = var.sql_administrator_password
  sku_name                     = var.sql_sku
  max_size_gb                  = var.sql_max_size_gb
  allow_azure_services         = true
  tags                         = local.common_tags
}

module "storage_account" {
  source = "../../modules/storage-account"

  name                     = local.storage_account_name
  location                 = var.location
  resource_group_name      = module.rg_storage.name
  account_tier             = "Standard"
  account_replication_type = var.storage_replication_type
  allow_public_blob_access = false
  tags                     = local.common_tags

  containers = {
    "uploads" = { access_type = "private" }
    "assets"  = { access_type = "private" }
  }
}

# =============================================================================
# LEVEL 4: App Service Plans (depend on: Resource Groups)
# =============================================================================

module "app_service_plan_api" {
  source = "../../modules/app-service-plan"

  name                = local.asp_api_name
  location            = var.location
  resource_group_name = module.rg_app.name
  os_type             = "Linux"
  sku_name            = var.app_service_sku
  worker_count        = var.app_service_worker_count
  tags                = local.common_tags
}

module "app_service_plan_web" {
  source = "../../modules/app-service-plan"

  name                = local.asp_web_name
  location            = var.location
  resource_group_name = module.rg_app.name
  os_type             = "Linux"
  sku_name            = var.app_service_sku
  worker_count        = var.app_service_worker_count
  tags                = local.common_tags
}

# =============================================================================
# LEVEL 5: App Services (depend on: App Service Plans, Data Resources)
# =============================================================================

module "app_service_api" {
  source = "../../modules/app-service"

  name                = local.app_api_name
  location            = var.location
  resource_group_name = module.rg_app.name
  service_plan_id     = module.app_service_plan_api.id
  always_on           = true
  tags                = local.common_tags

  application_stack = {
    dotnet_version = var.dotnet_version
    node_version   = null
    python_version = null
    java_version   = null
  }

  app_settings = {
    "ASPNETCORE_ENVIRONMENT" = "Development"
    "KeyVaultUri"            = module.key_vault.uri
  }

  connection_strings = [
    {
      name  = "DefaultConnection"
      type  = "SQLAzure"
      value = "Server=tcp:${module.sql_database.server_fqdn},1433;Database=${module.sql_database.database_name};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    }
  ]
}

module "app_service_web" {
  source = "../../modules/app-service"

  name                = local.app_web_name
  location            = var.location
  resource_group_name = module.rg_app.name
  service_plan_id     = module.app_service_plan_web.id
  always_on           = true
  tags                = local.common_tags

  application_stack = {
    dotnet_version = var.dotnet_version
    node_version   = null
    python_version = null
    java_version   = null
  }

  app_settings = {
    "ASPNETCORE_ENVIRONMENT" = "Development"
    "API_URL"                = "https://${module.app_service_api.default_hostname}"
  }
}
