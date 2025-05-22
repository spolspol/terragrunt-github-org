locals {
  # Organization settings
  org_name = basename(dirname(get_terragrunt_dir()))
  org_description = "Managed by Terragrunt"
  org_location    = "Global"
  
  # Default repository settings
  default_repo_visibility = "private"
  default_repo_topics     = ["managed-by-terragrunt"]
  
  # Default branch protection settings
  branch_protection = {
    required_status_checks = true
    enforce_admins        = true
    required_reviews      = 1
    dismiss_stale_reviews = true
  }
} 