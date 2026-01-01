# Azure Infrastructure Demo - GitHub Copilot Agents

Demo project showcasing GitHub Copilot and Copilot Agents for Azure Infrastructure as Code using Terraform.

## Architecture Overview

This project deploys a multi-tier Azure infrastructure across 5 resource groups:

```
                                    ┌─────────────────────────────────────────────────────────────┐
                                    │                         Azure                               │
                                    └─────────────────────────────────────────────────────────────┘
                                                              │
          ┌───────────────┬───────────────┬───────────────┬───────────────┬───────────────┐
          ▼               ▼               ▼               ▼               ▼               ▼
   ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
   │   rg-app    │ │ rg-network  │ │ rg-database │ │ rg-storage  │ │ rg-security │
   │             │ │             │ │             │ │             │ │             │
   │ ┌─────────┐ │ │ ┌─────────┐ │ │ ┌─────────┐ │ │ ┌─────────┐ │ │ ┌─────────┐ │
   │ │ ASP-API │ │ │ │  VNet   │ │ │ │   SQL   │ │ │ │ Storage │ │ │ │Key Vault│ │
   │ │ App-API │ │ │ │ ┌─────┐ │ │ │ │ Server  │ │ │ │ Account │ │ │ │         │ │
   │ └─────────┘ │ │ │ │ App │ │ │ │ ├─────────┤ │ │ │         │ │ │ │         │ │
   │ ┌─────────┐ │ │ │ └─────┘ │ │ │ │   SQL   │ │ │ │         │ │ │ │         │ │
   │ │ ASP-WEB │ │ │ │ ┌─────┐ │ │ │ │Database │ │ │ │         │ │ │ │         │ │
   │ │ App-WEB │ │ │ │ │Data │ │ │ │ └─────────┘ │ │ └─────────┘ │ │ └─────────┘ │
   │ └─────────┘ │ │ │ └─────┘ │ │ │             │ │             │ │             │
   └─────────────┘ │ └─────────┘ │ └─────────────┘ └─────────────┘ └─────────────┘
                   └─────────────┘
```

### Resources Deployed

| Resource | Resource Group | Description |
|----------|---------------|-------------|
| App Service (API) | rg-app-* | Backend API application (.NET 8) |
| App Service (WEB) | rg-app-* | Frontend web application (.NET 8) |
| App Service Plan (API) | rg-app-* | Dedicated hosting plan for API |
| App Service Plan (WEB) | rg-app-* | Dedicated hosting plan for WEB |
| Virtual Network | rg-network-* | Network foundation with 2 subnets |
| Azure SQL Server | rg-database-* | SQL Server instance |
| Azure SQL Database | rg-database-* | Application database |
| Storage Account | rg-storage-* | Blob storage for application data |
| Key Vault | rg-security-* | Secrets and key management |

## Project Structure

```
.
├── modules/                          # Reusable Terraform modules
│   ├── resource-group/              # Azure Resource Group
│   ├── app-service-plan/            # App Service Plan
│   ├── app-service/                 # Linux Web App
│   ├── virtual-network/             # VNet with configurable subnets
│   ├── sql-database/                # SQL Server + Database
│   ├── storage-account/             # Storage Account with containers
│   └── key-vault/                   # Key Vault with RBAC
│
├── environments/                     # Environment configurations
│   └── dev/                         # Development environment
│       ├── main.tf                  # Resource orchestration
│       ├── providers.tf             # Provider configuration
│       ├── variables.tf             # Variable declarations
│       ├── outputs.tf               # Output values
│       ├── locals.tf                # Computed values & naming
│       └── terraform.tfvars.example # Example variable values
│
└── README.md                        # This file
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.5.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.50
- Azure subscription with Contributor access

## Quick Start

### 1. Authenticate with Azure

```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### 2. Configure Variables

```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply
```

### 4. Access Outputs

```bash
terraform output
```

## Configuration

### Required Variables

| Variable | Description |
|----------|-------------|
| `sql_administrator_password` | Password for SQL Server admin (sensitive) |

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `environment` | `dev` | Environment name |
| `location` | `westeurope` | Azure region |
| `workload_name` | `demo` | Workload name for resource naming |
| `app_service_sku` | `S1` | App Service Plan SKU |
| `sql_sku` | `S0` | SQL Database SKU |

See [environments/dev/variables.tf](environments/dev/variables.tf) for all available variables.

## Naming Convention

Resources follow Azure CAF-inspired naming:

```
{resource-type}-{workload}-{environment}-{location}-{instance}
```

Examples:
- `rg-app-demo-dev-westeurope-001`
- `app-api-demo-dev-westeurope-001`
- `sql-demo-dev-westeurope-001`
- `stdemodevwe001` (storage accounts)

## Modules

Each module is self-contained and reusable:

| Module | Purpose |
|--------|---------|
| [resource-group](modules/resource-group/) | Creates resource groups with consistent tagging |
| [app-service-plan](modules/app-service-plan/) | Configurable App Service Plans |
| [app-service](modules/app-service/) | Linux Web Apps with managed identity |
| [virtual-network](modules/virtual-network/) | VNet with delegated subnets |
| [sql-database](modules/sql-database/) | SQL Server and Database with AD auth support |
| [storage-account](modules/storage-account/) | Storage with containers and soft delete |
| [key-vault](modules/key-vault/) | Key Vault with RBAC authorization |

## Security Features

- System-assigned managed identities on all services
- RBAC authorization for Key Vault
- TLS 1.2 minimum for all services
- HTTPS enforced on App Services
- FTPS disabled on App Services
- Soft delete enabled on Storage and Key Vault

## Future Enhancements

The Virtual Network is deployed with subnets configured for App Service delegation. VNet integration can be enabled by updating the App Service module with subnet IDs.

## Clean Up

```bash
cd environments/dev
terraform destroy
```

## License

MIT License - see [LICENSE](LICENSE) for details.
