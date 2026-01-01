# Deployment Examples

This document provides common usage examples for the `deploy.ps1` bootstrap script.

## Basic Operations

### Initialize Environment

Initialize Terraform for the dev environment:

```powershell
./deploy.ps1 -Environments @("dev") -Action init
```

### Validate Configuration

Validate Terraform configuration for all environments:

```powershell
./deploy.ps1 -Action validate
```

Validate a specific environment:

```powershell
./deploy.ps1 -Environments @("dev") -Action validate
```

### Plan Changes

Plan changes for the dev environment:

```powershell
./deploy.ps1 -Environments @("dev") -Action plan
```

Plan changes for multiple environments:

```powershell
./deploy.ps1 -Environments @("dev", "test") -Action plan
```

### Apply Changes

Apply changes with manual confirmation:

```powershell
./deploy.ps1 -Environments @("dev") -Action apply
```

Apply changes with auto-approval (useful for CI/CD):

```powershell
./deploy.ps1 -Environments @("dev") -Action apply -AutoApprove
```

### Destroy Infrastructure

Destroy infrastructure with confirmation:

```powershell
./deploy.ps1 -Environments @("dev") -Action destroy
```

Destroy with auto-approval:

```powershell
./deploy.ps1 -Environments @("dev") -Action destroy -AutoApprove
```

## Advanced Usage

### Skip Initialization

When Terraform is already initialized, skip the init step:

```powershell
./deploy.ps1 -Environments @("dev") -Action plan -SkipInit
```

### Deploy All Environments

Initialize all environments:

```powershell
./deploy.ps1 -Action init
```

Validate all environments:

```powershell
./deploy.ps1 -Action validate
```

Plan all environments:

```powershell
./deploy.ps1 -Action plan
```

## CI/CD Examples

### GitHub Actions Workflow

Example GitHub Actions workflow using the deploy script:

```yaml
name: Deploy Infrastructure

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0
      
      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      
      - name: Validate Configuration
        shell: pwsh
        run: ./deploy.ps1 -Action validate
      
      - name: Plan Dev Environment
        shell: pwsh
        run: ./deploy.ps1 -Environments @("dev") -Action plan
      
      - name: Apply Dev Environment
        if: github.ref == 'refs/heads/main'
        shell: pwsh
        run: ./deploy.ps1 -Environments @("dev") -Action apply -AutoApprove
```

### Azure DevOps Pipeline

Example Azure DevOps pipeline:

```yaml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

steps:
  - task: TerraformInstaller@0
    inputs:
      terraformVersion: '1.5.0'

  - task: AzureCLI@2
    displayName: 'Validate Infrastructure'
    inputs:
      azureSubscription: 'Azure Subscription'
      scriptType: 'pscore'
      scriptLocation: 'scriptPath'
      scriptPath: './deploy.ps1'
      arguments: '-Action validate'

  - task: AzureCLI@2
    displayName: 'Deploy Dev Environment'
    inputs:
      azureSubscription: 'Azure Subscription'
      scriptType: 'pscore'
      scriptLocation: 'scriptPath'
      scriptPath: './deploy.ps1'
      arguments: '-Environments @("dev") -Action apply -AutoApprove'
```

## Development Workflow

### Standard Development Cycle

1. **Make changes** to Terraform files
2. **Format code**:
   ```bash
   terraform fmt -recursive
   ```
3. **Validate changes**:
   ```powershell
   ./deploy.ps1 -Action validate
   ```
4. **Review plan**:
   ```powershell
   ./deploy.ps1 -Environments @("dev") -Action plan
   ```
5. **Apply changes**:
   ```powershell
   ./deploy.ps1 -Environments @("dev") -Action apply
   ```
6. **Commit and push**

### Quick Iteration

For rapid development, skip init when already initialized:

```powershell
# First time
./deploy.ps1 -Environments @("dev") -Action init

# Subsequent runs
./deploy.ps1 -Environments @("dev") -Action plan -SkipInit
./deploy.ps1 -Environments @("dev") -Action apply -SkipInit
```

## Troubleshooting Examples

### Check Script Help

```powershell
Get-Help ./deploy.ps1 -Detailed
```

### Test Single Environment

```powershell
./deploy.ps1 -Environments @("dev") -Action validate
```

### Dry Run (Plan Only)

Always run plan before apply:

```powershell
./deploy.ps1 -Environments @("dev") -Action plan
# Review the output
./deploy.ps1 -Environments @("dev") -Action apply
```

## Safety Tips

1. **Always run `plan` before `apply`** to review changes
2. **Never use `-AutoApprove` in production** without careful review
3. **Test in dev first** before deploying to test or prod
4. **Back up state files** before making major changes
5. **Use version control** for all Terraform configurations
6. **Review the output** of each command for errors or warnings
