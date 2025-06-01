include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Import template for infrastructure repository
include "repository_template" {
  path = find_in_parent_folders("_common/templates/repository.hcl")
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("_common/common.hcl"))
  org_vars    = read_terragrunt_config(find_in_parent_folders("org.hcl"))

  # Repository name from directory
  repository_name = basename(get_terragrunt_dir())
}


# Template inputs with infrastructure-specific overrides
inputs = {
  # Template configuration
  repository_type = "infrastructure"

  # Repository-specific overrides
  name         = local.repository_name
  description  = "GitHub Organization repository managed by Terragrunt with OpenTofu"
  homepage_url = local.org_vars.locals.website_url
  topics       = ["github", "infrastructure", "terragrunt", "automation"]
  visibility   = "private" # Enhanced module supports visibility setting

  # Team access (aligned with infrastructure access patterns)
  push_teams = ["devops"]

  # Enhanced security settings
  vulnerability_alerts = true

  # Infrastructure repositories need enhanced branch protection
  branch_protections_v4 = [
    {
      pattern                         = "main"
      allows_deletions                = false
      allows_force_pushes             = false
      blocks_creations                = false
      enforce_admins                  = true
      require_signed_commits          = true
      require_conversation_resolution = true
      required_linear_history         = true
      required_pull_request_reviews = {
        dismiss_stale_reviews           = true
        require_code_owner_reviews      = true
        required_approving_review_count = 2 # Higher requirement for infrastructure
      }
      required_status_checks = {
        strict   = true
        contexts = ["Validation Summary"]
      }
    }
  ]

  # Infrastructure-specific issue labels
  additional_labels = [
    {
      name        = "update-member"
      description = "Update Member"
      color       = "4285F4"
    },
    {
      name        = "update-team"
      description = "Update Team"
      color       = "623CE4"
    },
    {
      name        = "update-repository"
      description = "Update Repository"
      color       = "fbca04"
    }
  ]
}
