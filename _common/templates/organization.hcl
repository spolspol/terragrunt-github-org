# Organization Settings Template
# This template provides standardized GitHub organization settings and configuration
# Include this template in your Terragrunt configurations for consistent organization setups

terraform {
  source = "github.com/mineiros-io/terraform-github-organization?ref=v0.9.0"
}

locals {
  # Default organization configuration
  default_organization_config = {
    # Basic organization identity
    billing_email = null # Must be provided in specific implementations
    name          = null # Must be provided in specific implementations
    description   = "Managed by Terragrunt with OpenTofu"
    company       = null # Must be provided in specific implementations
    blog          = null # Optional - organization website
    location      = null # Optional - organization location

    # Project settings
    has_organization_projects = false
    has_repository_projects   = false

    # Repository permissions - secure by default
    default_repository_permission            = "read"
    members_can_create_repositories          = true
    members_can_create_public_repositories   = false
    members_can_create_internal_repositories = false
    members_can_create_pages                 = false
    members_can_create_public_pages          = false
    members_can_fork_private_repositories    = false
    members_can_change_repository_visibility = false
    members_can_delete_repositories          = false
    members_can_delete_issues                = false

    # Security settings - production-grade defaults
    web_commit_signoff_required                                  = false
    advanced_security_enabled_for_new_repositories               = false
    dependabot_alerts_enabled_for_new_repositories               = false
    dependabot_security_updates_enabled_for_new_repositories     = false # Manual review preferred
    dependency_graph_enabled_for_new_repositories                = false
    secret_scanning_enabled_for_new_repositories                 = false
    secret_scanning_push_protection_enabled_for_new_repositories = false
    secret_scanning_validity_checks_enabled                      = false
  }

  # Environment-specific organization settings
  env_organization_configs = {
    production = {
      # Enhanced security for production
      web_commit_signoff_required                              = true
      dependabot_security_updates_enabled_for_new_repositories = false # Manual review
      members_can_create_public_repositories                   = false
      members_can_fork_private_repositories                    = false
    }
    non-production = {
      # Slightly relaxed for development
      web_commit_signoff_required                              = false
      dependabot_security_updates_enabled_for_new_repositories = true  # Auto-update in dev
      members_can_create_public_repositories                   = false # Still restricted
      members_can_fork_private_repositories                    = true  # Allow for development
    }
  }

  # Default organization projects
  default_projects = []
}

# Default inputs - these will be merged with specific configurations
inputs = {
  # Organization settings - merge default with environment-specific
  settings = merge(
    local.default_organization_config,
    lookup(local.env_organization_configs, try(var.environment_type, "production"), {})
  )

  # Organization projects
  projects = try(var.projects, local.default_projects)

  # Labels for organization resources
  labels = {
    managed_by  = "terragrunt"
    component   = "organization"
    environment = try(var.environment_type, "production")
  }
}
