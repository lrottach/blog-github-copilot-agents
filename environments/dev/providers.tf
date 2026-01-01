# -----------------------------------------------------------------------------
# Terraform and Provider Configuration
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.14"
    }
  }

  # Uncomment and configure for remote state storage
  # backend "azurerm" {
  #   resource_group_name  = "rg-terraform-state"
  #   storage_account_name = "stterraformstate"
  #   container_name       = "tfstate"
  #   key                  = "blog-copilot-agents/dev.tfstate"
  # }
}

# -----------------------------------------------------------------------------
# Azure Provider Configuration
# -----------------------------------------------------------------------------

provider "azurerm" {
  features {
    key_vault {
      # In dev, allow purging soft-deleted vaults
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      # In dev, allow deletion of non-empty resource groups
      prevent_deletion_if_contains_resources = false
    }
  }
}
