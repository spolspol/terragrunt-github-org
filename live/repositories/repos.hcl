locals {
  # Repository-level shared configuration
  # This file contains default settings for all repositories

  # Get template configurations
  common_vars   = read_terragrunt_config(find_in_parent_folders("_common/common.hcl"))
  repo_template = read_terragrunt_config(find_in_parent_folders("_common/templates/repository.hcl"))

  # Default repository settings
  default_repository_settings = merge(
    local.repo_template.locals.default_repository_config,
    local.repo_template.locals.unified_repository_config,
    {
      # Default overrides
      description = "Repository managed by Terragrunt with OpenTofu"
      topics      = local.common_vars.locals.github_defaults.repository_defaults.topics

      # Enhanced branch protection
      branch_protections_v4 = [local.repo_template.locals.generate_branch_protection]

      # Default issue labels for all repositories
      issue_labels = local.common_vars.locals.default_issue_labels
    }
  )

  # Infrastructure repository specific settings
  infrastructure_repository_settings = merge(
    local.default_repository_settings,
    local.repo_template.locals.repository_type_templates.infrastructure,
    {
      description = "Infrastructure repository managed by Terragrunt with OpenTofu"
    }
  )

  # API repository specific settings
  api_repository_settings = merge(
    local.default_repository_settings,
    local.repo_template.locals.repository_type_templates.api,
    {
      description = "API repository"
    }
  )
}
