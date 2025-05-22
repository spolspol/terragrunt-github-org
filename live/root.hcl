locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  org_vars    = read_terragrunt_config(find_in_parent_folders("org.hcl"))
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "local" {
    path = "${get_terragrunt_dir()}/terraform.tfstate"
  }
}
EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "github" {
  owner = "${local.common_vars.locals.owner}"
  token = "${local.common_vars.locals.github_token}"
}
EOF
}