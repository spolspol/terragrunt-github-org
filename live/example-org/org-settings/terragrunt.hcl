include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  org_vars    = read_terragrunt_config(find_in_parent_folders("org.hcl"))
}

terraform {
  source = "github.com/mineiros-io/terraform-github-organization?ref=v0.9.0"
}

inputs = merge(
  local.common_vars.locals,
  local.org_vars.locals,
  {
    settings = {
      billing_email            = "billing@example.com"
      email                    = "info@example.com"
      name                     = local.org_vars.locals.org_name
      description              = local.org_vars.locals.org_description
      company                  = local.org_name
      blog                     = "https://example.com"
      twitter_username         = null
      location                 = local.org_vars.locals.org_location
      has_organization_projects = false
      has_repository_projects  = false
      
      # Repository Permissions
      default_repository_permission            = "read"
      members_can_create_repositories          = true
      members_can_create_public_repositories   = false
      members_can_create_internal_repositories = false
      members_can_create_pages                 = false
      members_can_create_public_pages          = false
      members_can_create_private_pages         = false
      members_can_fork_private_repositories    = false

      # Security Settings
      web_commit_signoff_required                                  = true
      advanced_security_enabled_for_new_repositories               = true
      dependabot_alerts_enabled_for_new_repositories               = true
      dependabot_security_updates_enabled_for_new_repositories     = false
      dependency_graph_enabled_for_new_repositories                = false
      secret_scanning_enabled_for_new_repositories                 = true
      secret_scanning_push_protection_enabled_for_new_repositories = true
    }
  }
) 