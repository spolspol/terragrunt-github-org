# Environment Template
# This template provides standardized GitHub environment configuration
# Include this template in your Terragrunt configurations for consistent environment setups

locals {
  # Default environment configuration
  default_environment_config = {
    wait_timer          = 0     # No wait time by default
    can_admins_bypass   = false # Admins must follow protection rules
    prevent_self_review = true  # Prevent self-approval

    # Default deployment branch policy
    deployment_branch_policy = {
      protected_branches     = true  # Only protected branches can deploy
      custom_branch_policies = false # Don't use custom patterns by default
    }

    # Default reviewers
    reviewers = [] # No required reviewers by default

    # Default variables and secrets
    variables = {}
    secrets   = {}
  }

  # Environment type configurations
  env_type_configs = {
    production = {
      # Strict controls for production
      wait_timer          = 300   # 5 minute wait time
      can_admins_bypass   = false # Even admins must wait
      prevent_self_review = true  # No self-approval

      deployment_branch_policy = {
        protected_branches     = true
        custom_branch_policies = false
      }

      # Require manual approval for production
      require_manual_approval = true
    }

    staging = {
      # Moderate controls for staging
      wait_timer          = 60   # 1 minute wait time
      can_admins_bypass   = true # Admins can bypass for urgent fixes
      prevent_self_review = true # No self-approval

      deployment_branch_policy = {
        protected_branches     = true
        custom_branch_policies = true
      }

      require_manual_approval = false
    }

    development = {
      # Relaxed controls for development
      wait_timer          = 0     # No wait time
      can_admins_bypass   = true  # Admins can bypass
      prevent_self_review = false # Allow self-approval for development

      deployment_branch_policy = {
        protected_branches     = false # Allow any branch
        custom_branch_policies = true
      }

      require_manual_approval = false
    }
  }

  # Environment templates based on purpose
  environment_purpose_templates = {
    # GCP project environment (aligned with tg-gcp-infra-live)
    gcp_project = {
      variables = {
        PROJECT_PREFIX = "bf"
        ENVIRONMENT    = null # Must be provided
        REGION         = "europe-west2"
        ZONE           = "europe-west2-a"
      }
      secrets = {
        # pragma: allowlist secret - Environment template with null/empty values for security
        GOOGLE_CREDENTIALS     = { plaintext = null } # Service account key
        PROJECT_ID             = { plaintext = null } # GCP project ID
        TERRAFORM_STATE_BUCKET = { plaintext = "" }   # Terraform state bucket
      }
      branch_patterns = ["main", "develop", "release/*"]
    }

    # Application deployment environment
    application = {
      variables = {
        NODE_ENV = null # Must be provided (development, staging, production)
        APP_NAME = null # Must be provided
        VERSION  = "latest"
      }
      secrets = {
        # pragma: allowlist secret - Environment template with null values for security
        DATABASE_URL = { plaintext = null } # Database connection string
        API_KEY      = { plaintext = null } # Application API key
        SECRET_KEY   = { plaintext = null } # Application secret key
      }
      branch_patterns = ["main", "develop", "feature/*", "hotfix/*"]
    }

    # Data processing environment
    data = {
      variables = {
        DATA_ENVIRONMENT = null # Must be provided
        DATASET_PREFIX   = "bf"
        REGION           = "europe-west2"
      }
      secrets = {
        # pragma: allowlist secret - Environment template with null values for security
        BIGQUERY_CREDENTIALS = { plaintext = null } # BigQuery service account
        STORAGE_BUCKET       = { plaintext = null } # Data storage bucket
        DATA_API_KEY         = { plaintext = null } # Data API access key
      }
      branch_patterns = ["main", "develop", "data/*"]
    }

    # Security and compliance environment
    security = {
      variables = {
        SECURITY_ENVIRONMENT = null # Must be provided
        COMPLIANCE_LEVEL     = "high"
        AUDIT_ENABLED        = "true"
      }
      secrets = {
        # pragma: allowlist secret - Environment template with null values for security
        SECURITY_API_KEY  = { plaintext = null } # Security service API key
        AUDIT_WEBHOOK_URL = { plaintext = null } # Audit logging webhook
        COMPLIANCE_TOKEN  = { plaintext = null } # Compliance service token
      }
      branch_patterns = ["main"] # Only main branch for security
    }
  }

  # Generate environment configurations
  generate_environment_configs = {
    for env_name, config in try(var.environment_definitions, {}) : env_name => merge(
      local.default_environment_config,
      lookup(local.env_type_configs, config.environment_type, {}),
      lookup(local.environment_purpose_templates, config.purpose, {}),
      config.overrides
    )
  }
}

# Default inputs for environment configuration
inputs = {
  # Environments - generated from environment definitions
  environments = [
    for env_name, config in local.generate_environment_configs : merge(
      config,
      {
        name = env_name

        # Merge variables with defaults
        variables = merge(
          try(config.variables, {}),
          try(var.environment_variables[env_name], {}),
          {
            MANAGED_BY = "terragrunt"
            REPOSITORY = try(var.repository_name, basename(get_terragrunt_dir()))
          }
        )

        # Merge secrets (be careful with sensitive data)
        secrets = merge(
          try(config.secrets, {}),
          try(var.environment_secrets[env_name], {})
        )

        # Set branch patterns
        branch_patterns = try(
          var.environment_branch_patterns[env_name],
          config.branch_patterns,
          ["main"]
        )

        # Set reviewers if specified
        reviewers = try(
          var.environment_reviewers[env_name],
          config.reviewers,
          []
        )
      }
    )
  ]

  # Labels
  labels = {
    managed_by       = "terragrunt"
    component        = "environments"
    environment_type = try(var.environment_type, "production")
  }
}
