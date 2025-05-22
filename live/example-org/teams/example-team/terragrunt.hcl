include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  org_vars    = read_terragrunt_config(find_in_parent_folders("org.hcl"))
  team_vars   = read_terragrunt_config(find_in_parent_folders("teams.hcl"))
}

terraform {
  source = "github.com/mineiros-io/terraform-github-team?ref=v0.9.0"
}

inputs = merge(
  local.common_vars.inputs,
  local.team_vars.inputs.team_settings,
  {
    name        = "${basename(get_terragrunt_dir())}"
    description = "Example Team"
    members     = []
    maintainers = []
  }
) 