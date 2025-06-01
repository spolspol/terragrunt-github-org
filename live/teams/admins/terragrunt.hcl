# Include root configuration
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Import team template with terraform source
include "team_template" {
  path = find_in_parent_folders("_common/templates/team.hcl")
}

locals {
  common_vars   = read_terragrunt_config(find_in_parent_folders("_common/common.hcl"))
  team_template = read_terragrunt_config(find_in_parent_folders("_common/templates/team.hcl"))

  # Get team name from folder structure
  team_name = basename(get_terragrunt_dir())

  # Get team configuration from template
  team_config = merge(
    local.team_template.locals.default_team_config,
    local.team_template.locals.team_type_templates["admin"],
    {
      # Team-specific overrides can be added here
      description = "Organization administrators with full access to all repositories and settings"
    }
  )
}

inputs = merge(
  local.common_vars.locals.common_labels,
  {
    name        = local.team_name
    description = local.team_config.description
    privacy     = local.team_config.privacy
    # Explicitly declare team members - UPDATE WITH YOUR ADMIN USERNAMES
    members = [
      # Add your admin team members here
      # "admin-username1",
      # "admin-username2"
    ]
    maintainers = [
      # Add your admin team maintainers here
      # "admin-maintainer-username"
    ]

    # Admin team gets admin access to all repositories
    repositories = ["*"]
    permission   = "admin"
  }
)
