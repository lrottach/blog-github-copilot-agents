# Azure Infrastructure Demo - GitHub Copilot Agents

> **Warning**: This is a demo project for educational and demonstration purposes only. It is not intended for production use. The configurations may lack security hardening, monitoring, backup strategies, and other production-ready features required for real-world deployments.

Demo project showcasing GitHub Copilot and Copilot Agents for Azure Infrastructure as Code using Terraform.

## Quick Start

### Prerequisites

- Terraform >= 1.5.0
- Azure CLI (authenticated)
- Bash shell

### Deployment

The repository includes a bootstrap script (`deploy.sh`) that automates Terraform initialization and deployment across all environment stages.

#### Basic Usage

```bash
# Plan all stages (dry-run, no changes applied)
./deploy.sh

# Plan a specific stage
./deploy.sh --stage dev

# Apply changes to dev environment
./deploy.sh --apply --stage dev

# Apply changes to multiple stages
./deploy.sh --apply --stage dev --stage test

# Apply changes to all stages
./deploy.sh --apply --all
```

#### Script Options

- `-h, --help`: Show help message
- `-a, --apply`: Apply Terraform changes (default: plan only)
- `-s, --stage STAGE`: Deploy specific stage(s) (dev, test, prod)
- `--all`: Deploy all stages (default if no stage specified)

#### Manual Deployment

If you prefer to deploy manually:

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

## Project Structure

```
blog-github-copilot-agents/
├── deploy.sh                     # Bootstrap script for automated deployment
├── modules/                      # Reusable Terraform modules
│   ├── resource-group/
│   ├── app-service-plan/
│   ├── app-service/
│   ├── virtual-network/
│   ├── sql-database/
│   ├── storage-account/
│   └── key-vault/
└── environments/                 # Environment configurations
    ├── dev/                      # Development environment
    ├── test/                     # Test environment (placeholder)
    └── prod/                     # Production environment (placeholder)
```
