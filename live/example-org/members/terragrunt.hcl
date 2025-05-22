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
    # Member management - Replace with actual members
    members = [
      "example-member-1",
      "example-member-2"
    ]

    # Organization Admins - Replace with actual admins
    admins = [
      "example-admin-1"
    ]

    # All Members Team
    all_members_team_name       = "${local.org_name}-all-members"
    all_members_team_visibility = "secret"
    catch_non_existing_members  = false

    # Blocked Users (if any)
    blocked_users = []
  }
) 