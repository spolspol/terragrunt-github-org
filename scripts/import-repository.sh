#!/bin/bash

# Repository Import Script for GitHub Organization Management
# This script imports existing GitHub repositories into Terragrunt/OpenTofu state
# Usage: ./scripts/import-repository.sh <repository-name> [repository-path]

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
REPOSITORIES_DIR="$REPO_ROOT/live/repositories"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
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

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 <repository-name> [repository-path]

Arguments:
  repository-name    Name of the GitHub repository to import
  repository-path    Optional path to repository directory (defaults to live/repositories/<repository-name>)

Examples:
  $0 tg-github-org
  $0 my-api-service live/repositories/api-services/my-api-service

Environment Variables:
  ORG_GITHUB_TOKEN   GitHub token with organization permissions (required)

Description:
  This script imports an existing GitHub repository into the Terragrunt/OpenTofu state.
  It will:
  1. Validate the repository exists in the live/repositories directory
  2. Check that terragrunt.hcl exists in the target directory
  3. Verify the GitHub repository exists and is accessible
  4. Import the repository into the Terragrunt state
  5. Verify the import was successful

EOF
}

# Function to validate prerequisites
validate_prerequisites() {
    log_info "Validating prerequisites..."

    # Check if ORG_GITHUB_TOKEN is set
    if [ -z "$ORG_GITHUB_TOKEN" ]; then
        log_error "ORG_GITHUB_TOKEN environment variable is not set"
        log_info "Please set your GitHub token: export ORG_GITHUB_TOKEN=\"your_token_here\""
        exit 1
    fi

    # Check if terragrunt is available
    if ! command -v terragrunt &> /dev/null; then
        log_error "terragrunt command not found. Please install terragrunt."
        exit 1
    fi

    # Check if we're in the right directory
    if [ ! -f "$REPO_ROOT/root.hcl" ]; then
        log_error "root.hcl not found. Please run this script from the tg-github-org repository root or ensure paths are correct."
        exit 1
    fi

    log_success "Prerequisites validated"
}

# Function to validate repository directory
validate_repository_directory() {
    local repo_path="$1"

    log_info "Validating repository directory: $repo_path"

    if [ ! -d "$repo_path" ]; then
        log_error "Repository directory does not exist: $repo_path"
        log_info "Available repositories:"
        find "$REPOSITORIES_DIR" -name "terragrunt.hcl" -type f | xargs dirname | sort
        exit 1
    fi

    if [ ! -f "$repo_path/terragrunt.hcl" ]; then
        log_error "terragrunt.hcl not found in: $repo_path"
        log_info "Please ensure the repository configuration exists"
        exit 1
    fi

    log_success "Repository directory validated"
}

# Function to check if repository exists on GitHub
check_github_repository() {
    local repo_name="$1"

    log_info "Checking if repository '$repo_name' exists on GitHub..."

    # Use GitHub CLI if available, otherwise curl
    if command -v gh &> /dev/null; then
        if gh repo view "$repo_name" &> /dev/null; then
            log_success "Repository '$repo_name' found on GitHub"
            return 0
        else
            log_error "Repository '$repo_name' not found on GitHub or not accessible"
            return 1
        fi
    else
        # Fallback to curl with GitHub API
        local response=$(curl -s -H "Authorization: token $ORG_GITHUB_TOKEN" \
            "https://api.github.com/repos/$repo_name" | jq -r '.name // "null"')

        if [ "$response" != "null" ] && [ "$response" != "" ]; then
            log_success "Repository '$repo_name' found on GitHub"
            return 0
        else
            log_error "Repository '$repo_name' not found on GitHub or not accessible"
            return 1
        fi
    fi
}

# Function to determine organization from repository path
get_organization_from_path() {
    local repo_path="$1"

    # Extract organization from terragrunt.hcl or org.hcl
    local org_hcl="$REPO_ROOT/live/org.hcl"
    if [ -f "$org_hcl" ]; then
        # Try to extract owner from org.hcl using multiple patterns
        local owner

        # Pattern 1: owner = "value" - use cut to extract quoted value
        owner=$(grep -E '^\s*owner\s*=' "$org_hcl" | cut -d'"' -f2 | head -1)

        # Pattern 2: Look for any line with owner = and extract value
        if [ -z "$owner" ]; then
            owner=$(grep 'owner.*=' "$org_hcl" | cut -d'"' -f2 | head -1)
        fi

        if [ -n "$owner" ] && [ "$owner" != "" ]; then
            echo "$owner"
            return 0
        fi
    fi

    # Check for common organization names in repository configurations
    if [ -f "$repo_path/terragrunt.hcl" ]; then
        local owner=$(grep -r "your-organization\|org-" "$repo_path" | head -1 | sed 's/.*your-organization.*/your-organization/' | head -1)
        if [ "$owner" = "your-organization" ]; then
            echo "your-organization"
            return 0
        fi
    fi

    # Fallback: ask user for organization
    log_warning "Could not determine organization automatically"
    read -p "Please enter the GitHub organization name: " org_name
    echo "$org_name"
}

# Function to import repository
import_repository() {
    local repo_name="$1"
    local repo_path="$2"
    local org_name="$3"
    local full_repo_name="${org_name}/${repo_name}"

    log_info "Starting import process for '$full_repo_name'..."

    # Change to repository directory
    cd "$repo_path"

    # Initialize terragrunt if needed
    log_info "Initializing Terragrunt..."
    if ! terragrunt init; then
        log_error "Failed to initialize Terragrunt in $repo_path"
        exit 1
    fi

    # Check if resource is already imported
    log_info "Checking current state..."
    if terragrunt state list | grep -q "github_repository.repository"; then
        log_warning "Repository appears to already be imported in state"
        read -p "Do you want to continue anyway? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            log_info "Import cancelled"
            exit 0
        fi
    fi

    # Perform the import
    log_info "Importing repository '$full_repo_name' into state..."
    if terragrunt import github_repository.repository "$repo_name"; then
        log_success "Repository '$repo_name' imported successfully"
    else
        log_error "Failed to import repository '$repo_name'"
        log_info "This could happen if:"
        log_info "  - The repository name doesn't match the GitHub repository"
        log_info "  - The resource address is different (check terragrunt.hcl)"
        log_info "  - Authentication issues with GitHub"
        exit 1
    fi

    # Verify import
    log_info "Verifying import..."
    if terragrunt state show github_repository.repository &> /dev/null; then
        log_success "Import verification successful"
    else
        log_error "Import verification failed"
        exit 1
    fi

    # Show current state
    log_info "Current repository state:"
    terragrunt state show github_repository.repository | head -10

    # Run plan to check for drift
    log_info "Checking for configuration drift..."
    if terragrunt plan -detailed-exitcode &> /dev/null; then
        log_success "No configuration drift detected"
    else
        exit_code=$?
        if [ $exit_code -eq 2 ]; then
            log_warning "Configuration drift detected - run 'terragrunt plan' to see details"
        else
            log_error "Error running terragrunt plan"
        fi
    fi

    log_success "Import process completed for '$repo_name'"
}

# Main function
main() {
    # Parse arguments
    if [ $# -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_usage
        exit 0
    fi

    local repo_name="$1"
    local repo_path="${2:-$REPOSITORIES_DIR/$repo_name}"

    # Make repo_path absolute if it's relative
    if [[ ! "$repo_path" = /* ]]; then
        repo_path="$REPO_ROOT/$repo_path"
    fi

    log_info "Repository Import Script"
    log_info "======================="
    log_info "Repository: $repo_name"
    log_info "Path: $repo_path"
    echo

    # Run validation steps
    validate_prerequisites
    validate_repository_directory "$repo_path"

    # Determine organization
    local org_name
    org_name=$(get_organization_from_path "$repo_path")
    if [ -z "$org_name" ]; then
        log_error "Could not determine organization name"
        exit 1
    fi

    log_info "Organization: $org_name"

    # Check if repository exists on GitHub
    if ! check_github_repository "${org_name}/${repo_name}"; then
        log_error "Cannot proceed with import"
        exit 1
    fi

    # Confirm import
    echo
    log_info "Ready to import repository:"
    log_info "  GitHub Repository: ${org_name}/${repo_name}"
    log_info "  Local Path: $repo_path"
    log_info "  Resource Address: github_repository.repository"
    echo

    read -p "Proceed with import? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Import cancelled"
        exit 0
    fi

    # Perform import
    import_repository "$repo_name" "$repo_path" "$org_name"

    echo
    log_success "Repository import completed successfully!"
    log_info "Next steps:"
    log_info "  1. Review any configuration drift with: cd $repo_path && terragrunt plan"
    log_info "  2. Apply any necessary changes with: terragrunt apply"
    log_info "  3. Commit the state changes to version control"
}

# Run main function with all arguments
main "$@"
