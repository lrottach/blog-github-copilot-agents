# GitHub Copilot Custom Instructions

## Project Overview

This repository contains a Terraform project for deploying Azure infrastructure. It implements a multi-tier architecture across multiple resource groups using modular, reusable components.

### Technology Stack

**Only the following tools, languages, and technologies are permitted in this project:**

| Category | Technology | Version |
|----------|------------|---------|
| Infrastructure as Code | Terraform | >= 1.5.0 |
| Cloud Provider | Microsoft Azure | - |
| Terraform Provider | AzureRM | ~> 4.14 |
| Primary Language | HCL (HashiCorp Configuration Language) | - |
| Scripting & Automation | PowerShell | >= 7.0 |

Do not introduce other languages, frameworks, or tools without explicit approval.

---

## Project Structure

```
blog-github-copilot-agents/
├── .github/                      # GitHub configurations
│   └── copilot-instructions.md   # This file
├── modules/                      # Reusable Terraform modules
│   ├── resource-group/           # Azure Resource Group
│   ├── app-service-plan/         # App Service Plan
│   ├── app-service/              # Linux Web App
│   ├── virtual-network/          # VNet with subnets
│   ├── sql-database/             # SQL Server + Database
│   ├── storage-account/          # Storage Account
│   └── key-vault/                # Key Vault
├── environments/                 # Environment configurations
│   ├── dev/                      # Development environment
│   ├── test/                     # Test environment (placeholder)
│   └── prod/                     # Production environment (placeholder)
└── README.md                     # Project documentation
```

### Module Structure

Each module follows a consistent structure:

```
module-name/
├── main.tf          # Resource definitions
├── variables.tf     # Input variables with validation
└── outputs.tf       # Output values
```

### Environment Structure

Root modules in `environments/` include:

```
environment-name/
├── main.tf                    # Resource orchestration
├── providers.tf               # Provider configuration
├── variables.tf               # Variable declarations
├── outputs.tf                 # Output values
├── locals.tf                  # Computed values & naming
└── terraform.tfvars.example   # Example variable values
```

---

## Terraform Conventions

### File Organization

| File | Purpose |
|------|---------|
| `main.tf` | Resource definitions and module calls |
| `variables.tf` | Input variable declarations with validation |
| `outputs.tf` | Output value definitions |
| `locals.tf` | Local values and computed configurations (root modules only) |
| `providers.tf` | Provider and backend configuration (root modules only) |

### Code Style

#### Resource Naming

Always use `"this"` as the resource alias:

```hcl
resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = var.tags
}
```

#### Comment Headers

Use consistent section dividers:

```hcl
# =============================================================================
# MAJOR SECTION TITLE
# =============================================================================

# -----------------------------------------------------------------------------
# Subsection Title
# -----------------------------------------------------------------------------
```

#### Variable Organization

Group variables into logical sections:

```hcl
# -----------------------------------------------------------------------------
# Global Configuration
# -----------------------------------------------------------------------------

variable "environment" { ... }
variable "location" { ... }

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------

variable "vnet_address_space" { ... }
```

#### Variable Validation

Always add validation blocks for restricted values:

```hcl
variable "environment" {
  description = "Environment name"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

#### Sensitive Values

Mark sensitive values appropriately:

```hcl
variable "sql_administrator_password" {
  description = "Administrator password for SQL Server"
  type        = string
  sensitive   = true
}

output "primary_access_key" {
  description = "The primary access key"
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}
```

#### Multiple Resources

Use `for_each` for creating multiple similar resources:

```hcl
resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
}
```

#### Optional Configurations

Use `dynamic` blocks for optional configurations:

```hcl
dynamic "delegation" {
  for_each = each.value.delegation != null ? [each.value.delegation] : []
  content {
    name = delegation.value.name
    service_delegation {
      name    = delegation.value.service_name
      actions = delegation.value.actions
    }
  }
}
```

---

## Naming Conventions

### Azure Resource Naming Pattern

```
{resource-type}-{workload}-{environment}-{location}-{instance}
```

### Resource Type Prefixes

| Resource | Prefix | Example |
|----------|--------|---------|
| Resource Group | `rg-` | `rg-app-demo-dev-westeurope-001` |
| Virtual Network | `vnet-` | `vnet-demo-dev-westeurope-001` |
| Subnet | `snet-` | `snet-app-demo-dev-westeurope-001` |
| App Service Plan | `asp-` | `asp-api-demo-dev-westeurope-001` |
| App Service | `app-` | `app-api-demo-dev-westeurope-001` |
| SQL Server | `sql-` | `sql-demo-dev-westeurope-001` |
| SQL Database | `sqldb-` | `sqldb-app-demo-dev-westeurope-001` |
| Storage Account | `st` | `stdemodewe001` (no hyphens, 24 char max) |
| Key Vault | `kv-` | `kv-demo-dev-we-001` (24 char max) |

### Region Abbreviations

| Region | Abbreviation |
|--------|--------------|
| West Europe | `we` |
| North Europe | `ne` |
| East US | `eus` |
| East US 2 | `eus2` |

---

## Azure Best Practices

When creating or modifying Azure resources, follow these guidelines:

- **Authentication:** Use system-assigned managed identities instead of keys/secrets
- **Key Vault:** Use RBAC authorization instead of access policies
- **TLS:** Enforce minimum TLS version 1.2 on all resources
- **HTTPS:** Enable HTTPS-only on App Services
- **FTPS:** Disable FTPS on App Services (use `ftps_state = "Disabled"`)
- **Soft Delete:** Enable soft delete on Key Vault and Storage Account
- **Tags:** Apply common tags to all resources for cost tracking and organization

---

## Git and Commit Guidelines

### Commit Message Format

```
<type>: <short description>

[optional body with more details]
```

### Commit Message Prefixes

| Prefix | Description | Example |
|--------|-------------|---------|
| `feat:` | New feature or functionality | `feat: add storage account module` |
| `fix:` | Bug fix | `fix: correct subnet delegation configuration` |
| `docs:` | Documentation changes | `docs: update README with deployment steps` |
| `refactor:` | Code refactoring without behavior change | `refactor: simplify variable naming in locals` |
| `test:` | Adding or updating tests | `test: add validation for SQL SKU values` |
| `chore:` | Maintenance tasks | `chore: update provider version to 4.14` |
| `style:` | Code formatting/style changes | `style: fix terraform fmt violations` |

### Pull Request Title Format

```
<Type>: <Short description>
```

### Pull Request Title Prefixes

| Prefix | Description | Example |
|--------|-------------|---------|
| `Feature:` | New feature | `Feature: Add Key Vault module with RBAC` |
| `Fix:` | Bug fix | `Fix: Resolve storage container naming issue` |
| `Docs:` | Documentation | `Docs: Add architecture diagram to README` |
| `Refactor:` | Code refactoring | `Refactor: Consolidate naming logic in locals` |

### Pre-Commit Requirements

**Always run the following commands before committing any Terraform changes:**

```bash
terraform fmt -recursive
terraform validate
```

This ensures consistent formatting and catches syntax errors before they enter the repository.

### Commit Best Practices

- Keep commits atomic and focused on a single change
- Write clear, descriptive commit messages
- Reference issue numbers when applicable (e.g., `feat: add VNET module (#42)`)
- **Always run `terraform fmt -recursive` before committing** - this is mandatory
- Run `terraform validate` to ensure configuration is valid

---

## External Documentation Sources

GitHub Copilot is allowed to search and reference the following trusted documentation sources:

### Terraform Documentation

- [Terraform Registry](https://registry.terraform.io/) - Provider and module documentation
- [HashiCorp Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [AzureRM Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

### Microsoft Azure Documentation

- [Microsoft Learn - Azure](https://learn.microsoft.com/en-us/azure/)
- [Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/)
- [Azure Naming Conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)

---

## Security Guidelines

### Secrets Management

- **Never commit secrets** (passwords, keys, connection strings) to the repository
- Use `terraform.tfvars.example` files as templates (actual `.tfvars` files are gitignored)
- Store sensitive values in Azure Key Vault or use environment variables
- Mark all sensitive variables and outputs with `sensitive = true`

### Access Control

- Follow the principle of least privilege
- Use managed identities for service-to-service authentication
- Enable RBAC on Key Vault instead of access policies
- Configure network rules to restrict access where possible

### Validation

- Always run `terraform validate` before applying changes
- Review `terraform plan` output carefully before applying
- Use variable validation blocks to catch configuration errors early
