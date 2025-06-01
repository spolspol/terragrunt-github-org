# Webhook and Integration Template
# This template provides standardized GitHub webhook and integration configuration
# Include this template in your Terragrunt configurations for consistent webhook setups

locals {
  # Default webhook configuration
  default_webhook_config = {
    active = true
    events = ["push", "pull_request", "issues", "issue_comment"]

    # Security settings
    content_type = "json"
    insecure_ssl = false

    # Default configuration
    configuration = {
      url          = null # Must be provided in specific implementations
      content_type = "json"
      insecure_ssl = "0"
      secret       = null # Should be provided for security
    }
  }

  # Environment-specific webhook settings
  env_webhook_configs = {
    production = {
      # More comprehensive events for production monitoring
      events = [
        "push", "pull_request", "pull_request_review", "pull_request_review_comment",
        "issues", "issue_comment", "release", "deployment", "deployment_status",
        "check_run", "check_suite", "status", "security_advisory"
      ]
      insecure_ssl   = false
      require_secret = true
    }
    non-production = {
      # Basic events for development
      events         = ["push", "pull_request", "issues"]
      insecure_ssl   = false
      require_secret = false
    }
  }

  # Webhook type templates
  webhook_type_templates = {
    # Slack integration webhook
    slack = {
      events = ["push", "pull_request", "issues", "release"]
      configuration = {
        content_type = "application/json"
        insecure_ssl = "0"
      }
    }

    # CI/CD webhook (GitHub Actions, Jenkins, etc.)
    cicd = {
      events = [
        "push", "pull_request", "create", "delete",
        "release", "workflow_run", "check_run", "check_suite"
      ]
      configuration = {
        content_type = "application/json"
        insecure_ssl = "0"
      }
    }

    # Security monitoring webhook
    security = {
      events = [
        "security_advisory", "code_scanning_alert", "secret_scanning_alert",
        "push", "pull_request", "release"
      ]
      configuration = {
        content_type = "application/json"
        insecure_ssl = "0"
      }
    }

    # Deployment webhook
    deployment = {
      events = [
        "deployment", "deployment_status", "release", "push",
        "workflow_run", "check_run", "check_suite"
      ]
      configuration = {
        content_type = "application/json"
        insecure_ssl = "0"
      }
    }

    # Issue tracking webhook (Jira, Linear, etc.)
    issue_tracking = {
      events = [
        "issues", "issue_comment", "pull_request", "pull_request_review",
        "pull_request_review_comment", "project", "project_card", "project_column"
      ]
      configuration = {
        content_type = "application/json"
        insecure_ssl = "0"
      }
    }

    # Generic webhook for external services
    generic = {
      events = ["push", "pull_request", "issues", "release"]
      configuration = {
        content_type = "application/json"
        insecure_ssl = "0"
      }
    }
  }

  # Common webhook configurations for different services
  service_webhook_configs = {
    # Slack notifications
    slack_notifications = {
      url          = null # Must be provided: https://hooks.slack.com/services/...
      webhook_type = "slack"
      description  = "Slack notifications for repository events"
    }

    # Discord notifications
    discord_notifications = {
      url          = null # Must be provided: https://discord.com/api/webhooks/...
      webhook_type = "generic"
      description  = "Discord notifications for repository events"
    }

    # Microsoft Teams notifications
    teams_notifications = {
      url          = null # Must be provided: https://outlook.office.com/webhook/...
      webhook_type = "generic"
      description  = "Microsoft Teams notifications for repository events"
    }

    # Jenkins CI
    jenkins_ci = {
      url          = null # Must be provided: https://jenkins.example.com/github-webhook/
      webhook_type = "cicd"
      description  = "Jenkins CI/CD integration"
    }

    # Jira integration
    jira_integration = {
      url          = null # Must be provided: https://company.atlassian.net/...
      webhook_type = "issue_tracking"
      description  = "Jira issue tracking integration"
    }

    # Security monitoring
    security_monitoring = {
      url          = null # Must be provided: https://security.company.com/webhook
      webhook_type = "security"
      description  = "Security event monitoring"
    }

    # Deployment notifications
    deployment_notifications = {
      url          = null # Must be provided: https://deploy.company.com/webhook
      webhook_type = "deployment"
      description  = "Deployment status notifications"
    }
  }

  # Generate webhook configurations
  generate_webhook_configs = {
    for webhook_name, config in try(var.webhook_definitions, {}) : webhook_name => merge(
      local.default_webhook_config,
      lookup(local.env_webhook_configs, try(var.environment_type, "production"), {}),
      lookup(local.webhook_type_templates, config.webhook_type, local.webhook_type_templates.generic),
      {
        configuration = merge(
          local.default_webhook_config.configuration,
          {
            url    = config.url
            secret = try(config.secret, null)
          }
        )
      }
    )
  }
}

# Default inputs for webhook configuration
inputs = {
  # Webhooks - generated from webhook definitions
  webhooks = [
    for webhook_name, config in local.generate_webhook_configs : {
      url          = config.configuration.url
      content_type = config.configuration.content_type
      insecure_ssl = config.configuration.insecure_ssl == "1" ? true : false
      secret       = config.configuration.secret
      active       = try(config.active, true)
      events       = config.events
    }
    if config.configuration.url != null # Only create webhooks with valid URLs
  ]

  # Labels
  labels = {
    managed_by  = "terragrunt"
    component   = "webhooks"
    environment = try(var.environment_type, "production")
  }
}
