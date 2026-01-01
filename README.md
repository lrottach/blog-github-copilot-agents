# Azure Infrastructure Demo - GitHub Copilot Agents

> **Warning**: This is a demo project for educational and demonstration purposes only. It is not intended for production use. The configurations may lack security hardening, monitoring, backup strategies, and other production-ready features required for real-world deployments.

Demo project showcasing GitHub Copilot and Copilot Agents for Azure Infrastructure as Code using Terraform.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.5.0
- [PowerShell](https://github.com/PowerShell/PowerShell) >= 7.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (authenticated)
- Azure subscription with appropriate permissions

## Project Structure

```
blog-github-copilot-agents/
├── .github/                      # GitHub configurations
│   └── copilot-instructions.md   # Copilot custom instructions
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
│   ├── test/                     # Test environment
│   └── prod/                     # Production environment
├── deploy.ps1                    # Bootstrap deployment script
└── README.md                     # This file
```

## Quick Start

### 1. Authenticate with Azure

```bash
az login
az account set --subscription "<your-subscription-id>"
```

### 2. Configure Environment Variables

Copy the example variables file and update with your values:

```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your configuration
```

### 3. Deploy Infrastructure

Use the provided PowerShell bootstrap script to deploy:

```powershell
# Validate all environments
./deploy.ps1 -Action validate

# Plan dev environment
./deploy.ps1 -Environments @("dev") -Action plan

# Apply dev environment (with confirmation)
./deploy.ps1 -Environments @("dev") -Action apply

# Apply all environments (auto-approve)
./deploy.ps1 -Environments @("dev", "test", "prod") -Action apply -AutoApprove
```

## Deployment Script Usage

The `deploy.ps1` script provides a unified interface for Terraform operations across all environments.

### Parameters

| Parameter | Description | Default | Options |
|-----------|-------------|---------|---------|
| `-Environments` | Array of environments to process | `@("dev", "test", "prod")` | `dev`, `test`, `prod` |
| `-Action` | Terraform action to perform | `plan` | `init`, `validate`, `plan`, `apply`, `destroy` |
| `-AutoApprove` | Skip confirmation prompts | `false` | switch |
| `-SkipInit` | Skip Terraform initialization | `false` | switch |

### Examples

**Initialize a single environment:**
```powershell
./deploy.ps1 -Environments @("dev") -Action init
```

**Validate all environments:**
```powershell
./deploy.ps1 -Action validate
```

**Plan dev and test environments:**
```powershell
./deploy.ps1 -Environments @("dev", "test") -Action plan
```

**Apply with auto-approval:**
```powershell
./deploy.ps1 -Environments @("dev") -Action apply -AutoApprove
```

**Destroy infrastructure:**
```powershell
./deploy.ps1 -Environments @("dev") -Action destroy
```

**Skip initialization (when already initialized):**
```powershell
./deploy.ps1 -Environments @("dev") -Action plan -SkipInit
```

## Manual Deployment

If you prefer to run Terraform commands manually:

```bash
cd environments/dev
terraform init
terraform validate
terraform plan
terraform apply
```

## Development Workflow

1. Make changes to Terraform configurations
2. Format code: `terraform fmt -recursive`
3. Validate changes: `./deploy.ps1 -Action validate`
4. Review plan: `./deploy.ps1 -Environments @("dev") -Action plan`
5. Apply changes: `./deploy.ps1 -Environments @("dev") -Action apply`
6. Commit and push changes

## Important Notes

- **Secrets Management**: Never commit `terraform.tfvars` files to version control
- **State Management**: Configure remote state backend for production use
- **Cost Awareness**: All environments deploy Azure resources that incur costs
- **Cleanup**: Use `./deploy.ps1 -Action destroy` to remove resources when done

## Troubleshooting

### Terraform not found
Ensure Terraform is installed and available in your PATH:
```bash
terraform version
```

### PowerShell version too old
Verify PowerShell version >= 7.0:
```powershell
$PSVersionTable.PSVersion
```

### Authentication issues
Re-authenticate with Azure:
```bash
az login
az account show
```

### State lock errors
If state is locked, ensure no other Terraform operations are running. You may need to manually unlock:
```bash
cd environments/dev
terraform force-unlock <lock-id>
```
