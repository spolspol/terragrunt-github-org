include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("_common/common.hcl"))
}

terraform {
  source = "github.com/mineiros-io/terraform-github-organization?ref=${local.common_vars.locals.module_versions.github_organization}"
}

inputs = merge(
  local.common_vars.locals.common_labels,
  {
    # Member management - UPDATE WITH YOUR ORGANIZATION'S MEMBERS
    members = [
      # Add your organization members here
      # "username1",
      # "username2",
    ]

    # Organization Admins - UPDATE WITH YOUR ORGANIZATION'S ADMINS
    admins = [
      # Add your organization admins here
      # "admin-username1",
      # "admin-username2"
    ]

    # All Members Team
    all_members_team_name       = "all-members"
    all_members_team_visibility = "secret"
    catch_non_existing_members  = false

    # Blocked Users (if any)
    blocked_users = []
  }
)
