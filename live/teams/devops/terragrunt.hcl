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
    local.team_template.locals.team_type_templates["devops"],
    {
      # Team-specific overrides can be added here
      description = "DevOps engineers responsible for infrastructure, CI/CD, and platform management"
    }
  )
}

inputs = merge(
  local.common_vars.locals.common_labels,
  {
    name        = local.team_name
    description = local.team_config.description
    privacy     = local.team_config.privacy
    # Explicitly declare team members - UPDATE WITH YOUR DEVOPS USERNAMES
    members = [
      # Add your devops team members here
      # "devops-username1",
      # "devops-username2"
    ]
    maintainers = [
      # Add your devops team maintainers here
      # "devops-maintainer-username"
    ]

    # DevOps team gets maintain access to infrastructure repositories
    repositories = ["tg-*", "*-infra", "*-terraform"]
    permission   = "maintain"
  }
)
