locals {
  # Repository defaults
  default_branch = "main"
  
  # Default repository features
  default_features = {
    has_issues    = true
    has_projects  = true
    has_wiki      = true
    has_downloads = false
  }

  # Default merge strategies
  default_merge_settings = {
    allow_merge_commit = true
    allow_rebase_merge = false
    allow_squash_merge = true
  }

  # Default branch protection settings
  default_branch_protection = {
    required_status_checks = {
      strict = true
      contexts = ["ci/github-actions"]
    }
    enforce_admins = true
    required_pull_request_reviews = {
      required_approving_review_count = 1
      dismiss_stale_reviews = true
    }
    require_signed_commits = true
  }
} 