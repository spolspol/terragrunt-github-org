# Teams Management Template
# This template provides standardized GitHub team management and configuration
# Include this template in your Terragrunt configurations for consistent team setups

locals {
  # Read common configuration for module versions
  common_vars = read_terragrunt_config(find_in_parent_folders("_common/common.hcl"))

  # Default team configuration
  default_team_config = {
    privacy                   = "closed" # Default to closed teams
    create_default_maintainer = false    # Don't auto-create maintainers
    ldap_dn                   = null     # LDAP integration if needed
    parent_team_id            = null     # No parent by default
  }

  # Unified team settings for organization
  unified_team_config = {
    default_privacy     = "closed" # Teams visible to members
    require_maintainers = true     # Ensure all teams have maintainers
    max_team_size       = 50       # Standard limit for team size
  }

  # Generic team type templates - focused on permissions and general configuration
  team_type_templates = {
    # Administrative team template - highest privileges
    admin = {
      privacy                   = "secret"
      create_default_maintainer = false
      description               = "Organization administrators with full access to all repositories and settings"
      repository_permissions    = "admin"
    }

    # Infrastructure/DevOps team template - maintain level access
    devops = {
      privacy                   = "closed"
      create_default_maintainer = false
      description               = "DevOps engineers responsible for infrastructure, CI/CD, and platform management"
      repository_permissions    = "maintain"
    }

    # Engineering team template - maintain level access for development teams
    engineering = {
      privacy                   = "closed"
      create_default_maintainer = false
      description               = "Engineering team with maintain access to development repositories"
      repository_permissions    = "maintain"
    }

    # Read-only team template - for analysts, stakeholders, etc.
    readonly = {
      privacy                   = "closed"
      create_default_maintainer = false
      description               = "Read-only access team for viewing repositories and documentation"
      repository_permissions    = "pull"
    }

    # Security team template - maintain level with higher privacy
    security = {
      privacy                   = "secret"
      create_default_maintainer = false
      description               = "Security team responsible for security policies, audits, and compliance"
      repository_permissions    = "maintain"
    }
  }

  # Team to repository access mapping (aligned with GCP project access)
  default_team_repository_access = {
    admins = {
      permission   = "admin"
      repositories = ["*"] # Access to all repositories
    }
    devops = {
      permission   = "maintain"
      repositories = ["tg-gcp-infra-live", "tg-github-org", "tg-*"]
    }
    data-engineering = {
      permission   = "push"
      repositories = ["data-*", "etl-*"]
    }
    data-analysts = {
      permission   = "pull"
      repositories = ["data-*", "analytics-*", "documentation"]
    }
    security = {
      permission   = "maintain"
      repositories = ["security-*", "policy-*", "compliance-*"]
    }
  }

  # Helper function to generate team configurations based on inputs
  # Note: This will be populated when the template is used with actual inputs
}

terraform {
  source = "github.com/mineiros-io/terraform-github-team?ref=${local.common_vars.locals.module_versions.github_team}"
}
