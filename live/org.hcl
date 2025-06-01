locals {
  # Organization-level configuration
  # This file contains shared settings for organization-level resources

  # Basic organization configuration (merged from common.hcl)
  owner        = "your-organization"
  github_token = get_env("ORG_GITHUB_TOKEN")

  # Import common configurations from _common
  common_config = read_terragrunt_config(find_in_parent_folders("_common/common.hcl"))

  # Organization identity - UPDATE THESE VALUES FOR YOUR ORGANIZATION
  org_name        = "your-organization"
  org_description = "Your Organization Description"
  company_name    = "Your Company Name"
  website_url     = "https://your-organization.com"
  org_location    = "Your Location"
  billing_email   = "admin@your-organization.com"

  # Organization labels
  org_labels = {
    organization = "your-organization"
    managed_by   = "terragrunt"
    component    = "github-org"
  }

  # Default security settings
  org_security = {
    # Branch protection defaults
    required_linear_history         = true
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    require_conversation_resolution = true
    enforce_admins                  = true
    allow_force_pushes              = false
    allow_deletions                 = false
    required_reviewers              = 1
    required_status_checks          = []

    # Organization security
    web_commit_signoff_required = true
  }
}
