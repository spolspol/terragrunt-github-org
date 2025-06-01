# Repository Management Template
# This template provides standardized GitHub repository configuration
# Include this template in your Terragrunt configurations for consistent repository setups

terraform {
  source = "git::https://github.com/your-org/terraform-github-repository.git?ref=v0.20.0-pre1"
}

locals {
  # Default repository configuration
  default_repository_config = {
    # Basic repository settings
    description            = "Repository managed by Terragrunt with OpenTofu"
    homepage_url           = null # Override in specific implementations
    private                = true
    has_issues             = true
    has_projects           = false
    has_wiki               = false
    allow_merge_commit     = false
    allow_rebase_merge     = false
    allow_squash_merge     = true
    allow_auto_merge       = false
    delete_branch_on_merge = true
    is_template            = false
    has_downloads          = false
    auto_init              = true
    gitignore_template     = null # Override based on repository type
    license_template       = ""
    archived               = false
    topics                 = ["your-organization", "managed-by-terragrunt"]

    # Security settings
    vulnerability_alerts                    = true
    ignore_vulnerability_alerts_during_read = false
    visibility                              = "private" # Enhanced module supports visibility

    # Default team access
    admin_teams    = ["admins"]
    push_teams     = ["devops"]
    maintain_teams = []
    pull_teams     = []
    triage_teams   = []

    # Default secrets and variables
    plaintext_secrets = {}
    encrypted_secrets = {}

    # Default webhooks
    webhooks = []

    # Default environments (enhanced module feature)
    environments = []

    # Advanced repository settings supported by enhanced module
    template       = null
    template_owner = null
    default_branch = "main"

    # Default deploy keys
    deploy_keys_computed = []

    # Default autolink references
    autolink_references = []

    # Default app installations
    app_installations = []

    # Default issue labels
    issue_labels = [] # Will use common labels from _common/common.hcl
  }

  # Unified repository settings for organization
  unified_repository_config = {
    # Enhanced security settings
    vulnerability_alerts = true
    allow_merge_commit   = false
    allow_rebase_merge   = false
    allow_auto_merge     = false

    # Branch protection settings
    required_status_checks          = ["ci", "security-scan", "compliance-check"]
    required_reviewers              = 2
    enforce_admins                  = true
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    require_conversation_resolution = true
    required_linear_history         = true
    allow_force_pushes              = false
    allow_deletions                 = false
  }

  # Repository type templates
  repository_type_templates = {
    # Basic repository template
    basic = {
      topics     = ["your-organization", "managed-by-terragrunt"]
      push_teams = ["admins"]
      visibility = "private"
    }

    # Infrastructure repository template
    infrastructure = {
      gitignore_template = "Terraform"
      topics             = ["your-organization", "managed-by-terragrunt", "infrastructure", "terraform"]
      push_teams         = ["devops", "data-engineering"]
      has_wiki           = true # Enable wiki for infrastructure documentation
      visibility         = "private"
      # Enhanced security for infrastructure
      vulnerability_alerts = true
    }

    # API repository template
    api = {
      gitignore_template = "Node"
      topics             = ["your-organization", "managed-by-terragrunt", "api", "application"]
      push_teams         = ["devops"]
      visibility         = "private"
      # API-specific settings
      vulnerability_alerts = true
    }

    # Data repository template
    data = {
      gitignore_template = "Python"
      topics             = ["your-organization", "managed-by-terragrunt", "data", "analytics"]
      push_teams         = ["data-engineering"]
      pull_teams         = ["data-analysts"]
      visibility         = "private"
    }

    # Documentation repository template
    documentation = {
      gitignore_template = "Jekyll"
      topics             = ["your-organization", "managed-by-terragrunt", "documentation"]
      push_teams         = ["devops", "data-engineering"]
      pull_teams         = ["data-analysts"]
      visibility         = "internal" # Internal visibility for docs
    }

    # Security repository template
    security = {
      gitignore_template   = "Python"
      topics               = ["your-organization", "managed-by-terragrunt", "security", "compliance"]
      push_teams           = ["security", "devops"]
      visibility           = "private" # Always private for security repos
      vulnerability_alerts = true
    }
  }

  # Generate branch protection with organization defaults
  generate_branch_protection = {
    pattern                         = "main"
    allows_deletions                = false
    allows_force_pushes             = false
    blocks_creations                = false
    enforce_admins                  = true
    require_conversation_resolution = true
    require_signed_commits          = false
    required_linear_history         = true
    required_pull_request_reviews = {
      dismiss_stale_reviews           = true
      require_code_owner_reviews      = true
      required_approving_review_count = 2
    }
    required_status_checks = {
      strict   = true
      contexts = ["ci", "security-scan", "compliance-check"]
    }
  }
}

# Default inputs - these will be merged with specific configurations
inputs = merge(
  local.default_repository_config,
  local.unified_repository_config,
  local.repository_type_templates["basic"],
  {
    # Repository name - auto-derived from directory name
    name = basename(get_terragrunt_dir())

    # Default branch protection
    branch_protections_v4 = [local.generate_branch_protection]

    # Issue labels from common configuration
    issue_labels = []

    # Labels
    labels = {
      managed_by      = "terragrunt"
      component       = "repository"
      repository_type = "basic"
    }
  }
)
