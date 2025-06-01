locals {
  # Common naming conventions - UPDATE THESE FOR YOUR ORGANIZATION
  name_prefix = "org"  # Short prefix for your organization
  org_name    = "your-organization"

  # Comprehensive module versions - centralized for consistency
  module_versions = {
    # GitHub modules
    github_organization = "v0.9.0"
    github_repository   = "v0.18.0"
    github_team         = "v0.9.0"

    # Custom modules with enhanced features
    github_repository_custom = "feature/environments" # Enhanced module with environment support

    # External modules
    null_label = "v0.25.0"
  }

  # GitHub organization defaults
  github_defaults = {
    # Security settings (organization-grade)
    security = {
      web_commit_signoff_required                                  = true
      advanced_security_enabled_for_new_repositories               = true
      dependabot_alerts_enabled_for_new_repositories               = true
      dependabot_security_updates_enabled_for_new_repositories     = false
      dependency_graph_enabled_for_new_repositories                = true
      secret_scanning_enabled_for_new_repositories                 = true
      secret_scanning_push_protection_enabled_for_new_repositories = true
      secret_scanning_validity_checks_enabled                      = true
    }

    # Repository permissions (restrictive by default)
    repository_permissions = {
      default_repository_permission            = "read"
      members_can_create_repositories          = true
      members_can_create_public_repositories   = false
      members_can_create_internal_repositories = false
      members_can_fork_private_repositories    = false
      members_can_change_repository_visibility = false
      members_can_delete_repositories          = false
    }

    # Default repository settings
    repository_defaults = {
      private                = true
      has_issues             = true
      has_projects           = false
      has_wiki               = false
      allow_merge_commit     = false
      allow_rebase_merge     = false
      allow_squash_merge     = true
      allow_auto_merge       = false
      delete_branch_on_merge = true
      auto_init              = true
      gitignore_template     = "Terraform"
      license_template       = ""
      archived               = false
      topics                 = ["your-organization", "managed-by-terragrunt"]

      # Default branch protection
      branch_protection = {
        pattern                         = "main"
        allows_deletions                = false
        allows_force_pushes             = false
        blocks_creations                = false
        enforce_admins                  = false
        require_conversation_resolution = true
        # require_signed_commits          = false # Enforced at Org level, breaks tf if set.
        required_linear_history = true
        required_pull_request_reviews = {
          dismiss_stale_reviews           = true
          require_code_owner_reviews      = true
          required_approving_review_count = 1
        }
        required_status_checks = {
          strict   = false
          contexts = ["ci"]
        }
      }
    }

    # Team defaults
    team_defaults = {
      privacy                   = "closed"
      create_default_maintainer = false
      base_permissions          = "pull"
    }
  }

  # Unified organization settings
  unified_settings = {
    branch_protection_contexts = ["ci", "security-scan", "compliance-check"]
    required_reviewers         = 2
    environment_protection     = true
  }

  # Common labels applied to all resources
  common_labels = {
    terraform_managed = "true"
    repository        = "tg-github-org"
    owner             = "infrastructure-team"
    organization      = "your-organization"
  }

  # GitHub Apps and integrations
  github_apps = {
    dependabot = {
      enabled = true
      config = {
        version = 2
        updates = [
          {
            package-ecosystem = "terraform"
            directory         = "/"
            schedule = {
              interval = "weekly"
            }
          }
        ]
      }
    }
  }

  # Default issue labels (standardized across all repos)
  default_issue_labels = [
    {
      name        = "infrastructure"
      description = "Issues related to infrastructure management"
      color       = "4285F4"
    },
    {
      name        = "urgent"
      description = "Urgent issues requiring immediate attention"
      color       = "EA4335"
    },
    {
      name        = "bug"
      description = "Something isn't working"
      color       = "d73a4a"
    },
    {
      name        = "enhancement"
      description = "New feature or request"
      color       = "a2eeef"
    },
    {
      name        = "documentation"
      description = "Improvements or additions to documentation"
      color       = "0075ca"
    },
    {
      name        = "wip"
      description = "Work in progress"
      color       = "fbca04"
    },
    {
      name        = "terraform"
      description = "Terraform/OpenTofu related changes"
      color       = "623CE4"
    },
    {
      name        = "security"
      description = "Security-related issues or improvements"
      color       = "FF6B6B"
    }
  ]
}
