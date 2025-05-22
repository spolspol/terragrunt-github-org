include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  org_vars    = read_terragrunt_config(find_in_parent_folders("org.hcl"))
  repos_vars  = read_terragrunt_config(find_in_parent_folders("repos.hcl"))
  
  # Get repository name from folder structure
  repository_name = basename(get_terragrunt_dir())
}

terraform {
  source = "github.com/mineiros-io/terraform-github-repository?ref=v0.18.0"
}

inputs = merge(
  local.common_vars.locals,
  local.org_vars.locals,
  local.repos_vars.locals,
  {
    name        = local.repository_name
    description = "${local.repository_name} repository managed by Terragrunt"
    visibility  = local.org_vars.locals.default_repo_visibility
    topics      = local.org_vars.locals.default_repo_topics

    # Features from repos.hcl
    has_issues    = local.repos_vars.locals.default_features.has_issues
    has_projects  = local.repos_vars.locals.default_features.has_projects
    has_wiki      = local.repos_vars.locals.default_features.has_wiki
    has_downloads = local.repos_vars.locals.default_features.has_downloads

    # Merge settings from repos.hcl
    allow_merge_commit = local.repos_vars.locals.default_merge_settings.allow_merge_commit
    allow_rebase_merge = local.repos_vars.locals.default_merge_settings.allow_rebase_merge
    allow_squash_merge = local.repos_vars.locals.default_merge_settings.allow_squash_merge

    # Branch protection from repos.hcl
    branch_protections = [
      {
        branch                 = local.repos_vars.locals.default_branch
        enforce_admins        = local.repos_vars.locals.default_branch_protection.enforce_admins
        require_signed_commits = local.repos_vars.locals.default_branch_protection.require_signed_commits
        required_status_checks = local.repos_vars.locals.default_branch_protection.required_status_checks
        required_pull_request_reviews = local.repos_vars.locals.default_branch_protection.required_pull_request_reviews
      }
    ]

    # Example collaborators - Replace with actual users
    collaborators = [
      {
        username   = "example-member-1"
        permission = "push"
      },
      {
        username   = "example-member-2"
        permission = "maintain"
      }
    ]
  }
) 