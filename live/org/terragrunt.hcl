include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("_common/common.hcl"))
  org_vars    = read_terragrunt_config(find_in_parent_folders("org.hcl"))
}

terraform {
  source = "github.com/mineiros-io/terraform-github-organization?ref=${local.common_vars.locals.module_versions.github_organization}"
}

inputs = merge(
  local.common_vars.locals.common_labels,
  local.org_vars.locals.org_labels,
  {
    settings = merge(
      local.common_vars.locals.github_defaults.security,
      local.common_vars.locals.github_defaults.repository_permissions,
      {
        # Organization identity
        billing_email = local.org_vars.locals.billing_email
        name          = local.org_vars.locals.org_name
        description   = local.org_vars.locals.org_description
        company       = local.org_vars.locals.company_name
        blog          = local.org_vars.locals.website_url
        location      = local.org_vars.locals.org_location

        # Project settings
        has_organization_projects = false
        has_repository_projects   = false

        # Additional security settings
        web_commit_signoff_required = local.org_vars.locals.org_security.web_commit_signoff_required
      }
    )

    # Organization Projects
    projects = []
  }
)
