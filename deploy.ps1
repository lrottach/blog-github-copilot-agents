#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Bootstrap script for Terraform deployment across all environments.

.DESCRIPTION
    This script initializes, validates, plans, and optionally applies Terraform
    configurations for specified environments (dev, test, prod).

.PARAMETER Environments
    Array of environment names to deploy. Defaults to all environments.

.PARAMETER Action
    The Terraform action to perform: init, validate, plan, or apply.
    Defaults to 'plan'.

.PARAMETER AutoApprove
    Automatically approve Terraform apply without confirmation.

.PARAMETER SkipInit
    Skip the Terraform initialization step.

.EXAMPLE
    ./deploy.ps1 -Environments @("dev") -Action plan
    Plans the dev environment.

.EXAMPLE
    ./deploy.ps1 -Environments @("dev", "test", "prod") -Action apply -AutoApprove
    Applies all environments without confirmation.

.EXAMPLE
    ./deploy.ps1 -Action validate
    Validates all environments.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateSet("dev", "test", "prod")]
    [string[]]$Environments = @("dev", "test", "prod"),

    [Parameter(Mandatory = $false)]
    [ValidateSet("init", "validate", "plan", "apply", "destroy")]
    [string]$Action = "plan",

    [Parameter(Mandatory = $false)]
    [switch]$AutoApprove,

    [Parameter(Mandatory = $false)]
    [switch]$SkipInit
)

# -----------------------------------------------------------------------------
# Script Configuration
# -----------------------------------------------------------------------------

$ErrorActionPreference = "Stop"
$ScriptRoot = $PSScriptRoot
$EnvironmentsPath = Join-Path $ScriptRoot "environments"

# ANSI color codes for output formatting
$ColorReset = "`e[0m"
$ColorGreen = "`e[32m"
$ColorYellow = "`e[33m"
$ColorRed = "`e[31m"
$ColorBlue = "`e[34m"
$ColorCyan = "`e[36m"

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

function Write-Section {
    param([string]$Message)
    Write-Host ""
    Write-Host "${ColorCyan}=============================================================================${ColorReset}"
    Write-Host "${ColorCyan}$Message${ColorReset}"
    Write-Host "${ColorCyan}=============================================================================${ColorReset}"
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-Host "${ColorGreen}✓ $Message${ColorReset}"
}

function Write-Info {
    param([string]$Message)
    Write-Host "${ColorBlue}ℹ $Message${ColorReset}"
}

function Write-Warning {
    param([string]$Message)
    Write-Host "${ColorYellow}⚠ $Message${ColorReset}"
}

function Write-Error {
    param([string]$Message)
    Write-Host "${ColorRed}✗ $Message${ColorReset}"
}

function Test-TerraformInstalled {
    try {
        $version = terraform version -json 2>$null | ConvertFrom-Json
        Write-Success "Terraform $($version.terraform_version) is installed"
        return $true
    }
    catch {
        Write-Error "Terraform is not installed or not in PATH"
        Write-Info "Please install Terraform >= 1.5.0 from https://www.terraform.io/downloads"
        return $false
    }
}

function Test-EnvironmentExists {
    param([string]$Environment)
    
    $envPath = Join-Path $EnvironmentsPath $Environment
    if (Test-Path $envPath) {
        $mainTf = Join-Path $envPath "main.tf"
        if (Test-Path $mainTf) {
            return $true
        }
    }
    return $false
}

function Invoke-TerraformInit {
    param([string]$EnvironmentPath)
    
    Write-Info "Running: terraform init"
    terraform init -input=false
    
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform init failed with exit code $LASTEXITCODE"
    }
    
    Write-Success "Terraform initialization completed"
}

function Invoke-TerraformValidate {
    param([string]$EnvironmentPath)
    
    Write-Info "Running: terraform validate"
    terraform validate
    
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform validation failed with exit code $LASTEXITCODE"
    }
    
    Write-Success "Terraform validation passed"
}

function Invoke-TerraformFormat {
    param([string]$EnvironmentPath)
    
    Write-Info "Running: terraform fmt -check -recursive"
    terraform fmt -check -recursive
    
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Terraform formatting check failed - files need formatting"
        Write-Info "Run 'terraform fmt -recursive' to fix formatting"
    }
    else {
        Write-Success "Terraform formatting check passed"
    }
}

function Invoke-TerraformPlan {
    param([string]$EnvironmentPath)
    
    Write-Info "Running: terraform plan"
    terraform plan -input=false
    
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform plan failed with exit code $LASTEXITCODE"
    }
    
    Write-Success "Terraform plan completed"
}

function Invoke-TerraformApply {
    param(
        [string]$EnvironmentPath,
        [bool]$AutoApprove
    )
    
    if ($AutoApprove) {
        Write-Info "Running: terraform apply -auto-approve"
        terraform apply -input=false -auto-approve
    }
    else {
        Write-Info "Running: terraform apply"
        terraform apply -input=false
    }
    
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform apply failed with exit code $LASTEXITCODE"
    }
    
    Write-Success "Terraform apply completed"
}

function Invoke-TerraformDestroy {
    param(
        [string]$EnvironmentPath,
        [bool]$AutoApprove
    )
    
    Write-Warning "Destroying infrastructure for environment"
    
    if ($AutoApprove) {
        Write-Info "Running: terraform destroy -auto-approve"
        terraform destroy -input=false -auto-approve
    }
    else {
        Write-Info "Running: terraform destroy"
        terraform destroy -input=false
    }
    
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform destroy failed with exit code $LASTEXITCODE"
    }
    
    Write-Success "Terraform destroy completed"
}

function Invoke-TerraformAction {
    param(
        [string]$Environment,
        [string]$Action,
        [bool]$SkipInit,
        [bool]$AutoApprove
    )
    
    $envPath = Join-Path $EnvironmentsPath $Environment
    
    # Check if environment has configuration
    if (-not (Test-EnvironmentExists -Environment $Environment)) {
        Write-Warning "Environment '$Environment' does not have Terraform configuration (skipping)"
        return $false
    }
    
    Write-Section "Processing Environment: $Environment"
    Write-Info "Environment Path: $envPath"
    
    # Change to environment directory
    Push-Location $envPath
    
    try {
        # Initialize Terraform
        if (-not $SkipInit -or $Action -eq "init") {
            Invoke-TerraformInit -EnvironmentPath $envPath
        }
        
        # Run format check
        if ($Action -ne "init") {
            Invoke-TerraformFormat -EnvironmentPath $envPath
        }
        
        # Validate configuration
        if ($Action -ne "init") {
            Invoke-TerraformValidate -EnvironmentPath $envPath
        }
        
        # Execute the requested action
        switch ($Action) {
            "init" {
                # Already done above
            }
            "validate" {
                # Already done above
            }
            "plan" {
                Invoke-TerraformPlan -EnvironmentPath $envPath
            }
            "apply" {
                Invoke-TerraformApply -EnvironmentPath $envPath -AutoApprove $AutoApprove
            }
            "destroy" {
                Invoke-TerraformDestroy -EnvironmentPath $envPath -AutoApprove $AutoApprove
            }
        }
        
        Write-Success "Environment '$Environment' processed successfully"
        return $true
    }
    catch {
        Write-Error "Failed to process environment '$Environment': $_"
        return $false
    }
    finally {
        Pop-Location
    }
}

# -----------------------------------------------------------------------------
# Main Script
# -----------------------------------------------------------------------------

Write-Section "Terraform Bootstrap Script"

# Verify Terraform is installed
if (-not (Test-TerraformInstalled)) {
    exit 1
}

# Display configuration
Write-Info "Environments: $($Environments -join ', ')"
Write-Info "Action: $Action"
if ($AutoApprove) {
    Write-Warning "Auto-approve is enabled"
}
if ($SkipInit) {
    Write-Info "Skipping Terraform initialization"
}

# Process each environment
$results = @{}
foreach ($env in $Environments) {
    $success = Invoke-TerraformAction `
        -Environment $env `
        -Action $Action `
        -SkipInit $SkipInit `
        -AutoApprove $AutoApprove
    
    $results[$env] = $success
}

# Display summary
Write-Section "Deployment Summary"

$successCount = 0
$skippedCount = 0

foreach ($env in $Environments) {
    $status = $results[$env]
    if ($status -eq $true) {
        Write-Success "Environment '$env': Success"
        $successCount++
    }
    elseif ($status -eq $false) {
        Write-Error "Environment '$env': Failed or Skipped"
        $skippedCount++
    }
}

Write-Host ""
Write-Info "Total: $($Environments.Count) | Success: $successCount | Skipped: $skippedCount"

# Exit with appropriate code
if ($skippedCount -gt 0 -and $successCount -eq 0) {
    Write-Warning "All environments were skipped or failed"
    exit 1
}
elseif ($skippedCount -gt 0) {
    Write-Warning "Some environments were skipped or failed"
    exit 0
}
else {
    Write-Success "All environments processed successfully"
    exit 0
}
