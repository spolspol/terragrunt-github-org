# Root Terragrunt Configuration for GitHub Organization Management
# This is the root configuration that all units will inherit from.

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("_common/common.hcl"))
  org_vars    = read_terragrunt_config(find_in_parent_folders("org.hcl"))
}

# Remote state configuration - UPDATE WITH YOUR BACKEND CONFIGURATION
# Example configurations for different backends:

# Google Cloud Storage (GCS) Backend
remote_state {
  backend = "gcs"
  config = {
    bucket   = "your-terraform-state-bucket"
    prefix   = "github-org/${path_relative_to_include()}"
    project  = "your-gcp-project-id"
    location = "your-region"
  }

  # Enable state locking to prevent concurrent modifications
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Alternative: AWS S3 Backend (uncomment to use)
# remote_state {
#   backend = "s3"
#   config = {
#     bucket         = "your-terraform-state-bucket"
#     key            = "github-org/${path_relative_to_include()}/terraform.tfstate"
#     region         = "your-aws-region"
#     encrypt        = true
#     dynamodb_table = "your-terraform-locks-table"
#   }
#
#   generate = {
#     path      = "backend.tf"
#     if_exists = "overwrite_terragrunt"
#   }
# }

# Alternative: Azure Storage Backend (uncomment to use)
# remote_state {
#   backend = "azurerm"
#   config = {
#     resource_group_name  = "your-resource-group"
#     storage_account_name = "your-storage-account"
#     container_name       = "terraform-state"
#     key                  = "github-org/${path_relative_to_include()}/terraform.tfstate"
#   }
#
#   generate = {
#     path      = "backend.tf"
#     if_exists = "overwrite_terragrunt"
#   }
# }

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "github" {
  owner = "${local.org_vars.locals.owner}"
  token = "${local.org_vars.locals.github_token}"
}
EOF
}

# Define default inputs that will be merged with all child Terragrunt configurations
inputs = {}

# Terraform configuration
terraform_binary             = "tofu"
terraform_version_constraint = ">= 1.6.0"

# Extra arguments for terraform commands
terraform {
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
  }
}
