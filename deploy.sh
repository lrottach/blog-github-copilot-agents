#!/usr/bin/env bash

# =============================================================================
# Terraform Bootstrap and Deployment Script
# =============================================================================
# This script automates Terraform initialization and deployment across all
# environment stages (dev, test, prod). It handles terraform init, plan, and
# apply operations with proper error handling and logging.
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVIRONMENTS_DIR="${SCRIPT_DIR}/environments"
STAGES=("dev" "test" "prod")

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

# Print colored messages
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Print section header
print_header() {
    echo ""
    echo -e "${BLUE}=============================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}=============================================================================${NC}"
    echo ""
}

# Check if required tools are installed
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed. Please install Terraform >= 1.5.0"
        exit 1
    fi
    
    local tf_version=$(terraform version | head -n1 | awk '{print $2}')
    log_success "Terraform version: ${tf_version}"
}

# Validate environment directory exists and has required files
validate_environment() {
    local env=$1
    local env_path="${ENVIRONMENTS_DIR}/${env}"
    
    if [[ ! -d "${env_path}" ]]; then
        log_error "Environment directory does not exist: ${env_path}"
        return 1
    fi
    
    # Check if environment is configured (has more than just .gitkeep)
    if [[ ! -f "${env_path}/main.tf" ]]; then
        log_warning "Environment '${env}' is not configured (missing main.tf)"
        return 2
    fi
    
    return 0
}

# Initialize Terraform for an environment
terraform_init() {
    local env=$1
    local env_path="${ENVIRONMENTS_DIR}/${env}"
    
    log_info "Initializing Terraform for '${env}' environment..."
    
    if terraform -chdir="${env_path}" init -input=false; then
        log_success "Terraform initialized successfully for '${env}'"
        return 0
    else
        log_error "Terraform initialization failed for '${env}'"
        return 1
    fi
}

# Run Terraform plan for an environment
terraform_plan() {
    local env=$1
    local env_path="${ENVIRONMENTS_DIR}/${env}"
    
    log_info "Running Terraform plan for '${env}' environment..."
    
    if terraform -chdir="${env_path}" plan -input=false -out="${env}.tfplan"; then
        log_success "Terraform plan completed successfully for '${env}'"
        return 0
    else
        log_error "Terraform plan failed for '${env}'"
        return 1
    fi
}

# Apply Terraform configuration for an environment
terraform_apply() {
    local env=$1
    local env_path="${ENVIRONMENTS_DIR}/${env}"
    local auto_approve=${2:-false}
    
    log_info "Applying Terraform configuration for '${env}' environment..."
    
    if [[ "${auto_approve}" == "true" ]]; then
        if terraform -chdir="${env_path}" apply -input=false "${env}.tfplan"; then
            log_success "Terraform apply completed successfully for '${env}'"
            return 0
        else
            log_error "Terraform apply failed for '${env}'"
            return 1
        fi
    else
        log_warning "Skipping apply (dry-run mode). Use --apply flag to apply changes."
        return 0
    fi
}

# Deploy a single environment
deploy_environment() {
    local env=$1
    local auto_approve=${2:-false}
    
    print_header "Deploying ${env} Environment"
    
    # Validate environment
    if ! validate_environment "${env}"; then
        local validation_result=$?
        if [[ ${validation_result} -eq 2 ]]; then
            log_warning "Skipping unconfigured environment: ${env}"
            return 0
        else
            return 1
        fi
    fi
    
    # Initialize Terraform
    if ! terraform_init "${env}"; then
        return 1
    fi
    
    # Run Terraform plan
    if ! terraform_plan "${env}"; then
        return 1
    fi
    
    # Apply Terraform configuration
    if ! terraform_apply "${env}" "${auto_approve}"; then
        return 1
    fi
    
    log_success "Deployment of '${env}' environment completed successfully"
    return 0
}

# Show usage information
show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] [STAGE...]

Bootstrap and deploy Terraform configurations for multiple environments.

OPTIONS:
    -h, --help          Show this help message
    -a, --apply         Apply Terraform changes (default: plan only)
    -s, --stage STAGE   Deploy specific stage(s) (dev, test, prod)
                        Can be specified multiple times
    --all               Deploy all stages (default if no stage specified)

STAGES:
    dev                 Development environment
    test                Test environment
    prod                Production environment

EXAMPLES:
    # Plan all stages (dry-run)
    $(basename "$0")

    # Apply changes to dev environment
    $(basename "$0") --apply --stage dev

    # Apply changes to multiple specific stages
    $(basename "$0") --apply --stage dev --stage test

    # Apply changes to all stages
    $(basename "$0") --apply --all

EOF
}

# -----------------------------------------------------------------------------
# Main Script Logic
# -----------------------------------------------------------------------------

main() {
    local auto_approve=false
    local selected_stages=()
    local deploy_all=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -a|--apply)
                auto_approve=true
                shift
                ;;
            -s|--stage)
                if [[ -z "${2:-}" ]]; then
                    log_error "Missing stage argument for --stage option"
                    exit 1
                fi
                # Validate stage is one of the valid stages
                local valid_stage=false
                for stage in "${STAGES[@]}"; do
                    if [[ "$2" == "${stage}" ]]; then
                        valid_stage=true
                        break
                    fi
                done
                if [[ "${valid_stage}" == "false" ]]; then
                    log_error "Invalid stage: $2. Must be one of: ${STAGES[*]}"
                    exit 1
                fi
                selected_stages+=("$2")
                shift 2
                ;;
            --all)
                deploy_all=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Determine which stages to deploy
    if [[ ${#selected_stages[@]} -eq 0 ]] || [[ "${deploy_all}" == "true" ]]; then
        selected_stages=("${STAGES[@]}")
    fi
    
    # Print banner
    print_header "Terraform Bootstrap Script"
    log_info "Script directory: ${SCRIPT_DIR}"
    log_info "Environments directory: ${ENVIRONMENTS_DIR}"
    
    if [[ "${auto_approve}" == "true" ]]; then
        log_warning "Auto-approve is enabled. Changes will be applied automatically."
    else
        log_info "Running in plan-only mode. Use --apply to apply changes."
    fi
    
    echo ""
    log_info "Stages to deploy: ${selected_stages[*]}"
    echo ""
    
    # Check prerequisites
    check_prerequisites
    echo ""
    
    # Deploy each selected stage
    local failed_stages=()
    for stage in "${selected_stages[@]}"; do
        if ! deploy_environment "${stage}" "${auto_approve}"; then
            failed_stages+=("${stage}")
            log_error "Deployment failed for stage: ${stage}"
        fi
    done
    
    # Print summary
    print_header "Deployment Summary"
    
    local total_stages=${#selected_stages[@]}
    local failed_count=${#failed_stages[@]}
    local success_count=$((total_stages - failed_count))
    
    log_info "Total stages processed: ${total_stages}"
    log_success "Successful deployments: ${success_count}"
    
    if [[ ${failed_count} -gt 0 ]]; then
        log_error "Failed deployments: ${failed_count}"
        log_error "Failed stages: ${failed_stages[*]}"
        exit 1
    else
        log_success "All deployments completed successfully!"
        exit 0
    fi
}

# Run main function
main "$@"
