# Labels Template
# This template provides standardized GitHub issue and PR label configuration
# Include this template in your Terragrunt configurations for consistent labeling

locals {
  # Default label configuration
  default_label_config = {
    # Label categories and their colors
    label_categories = {
      # Priority labels
      priority = {
        color_base = "d73a4a" # Red base
        labels = {
          "priority/critical" = { description = "Critical priority - immediate attention required", color = "d73a4a" }
          "priority/high"     = { description = "High priority", color = "e99695" }
          "priority/medium"   = { description = "Medium priority", color = "f9d0c4" }
          "priority/low"      = { description = "Low priority", color = "fef2f2" }
        }
      }

      # Type labels
      type = {
        color_base = "0075ca" # Blue base
        labels = {
          "type/bug"           = { description = "Something isn't working", color = "d73a4a" }
          "type/enhancement"   = { description = "New feature or request", color = "a2eeef" }
          "type/documentation" = { description = "Improvements or additions to documentation", color = "0075ca" }
          "type/question"      = { description = "Further information is requested", color = "d876e3" }
          "type/duplicate"     = { description = "This issue or pull request already exists", color = "cfd3d7" }
          "type/invalid"       = { description = "This doesn't seem right", color = "e4e669" }
          "type/wontfix"       = { description = "This will not be worked on", color = "ffffff" }
        }
      }

      # Status labels
      status = {
        color_base = "fbca04" # Yellow base
        labels = {
          "status/wip"           = { description = "Work in progress", color = "fbca04" }
          "status/blocked"       = { description = "Blocked by external dependency", color = "d73a4a" }
          "status/help-wanted"   = { description = "Extra attention is needed", color = "008672" }
          "status/needs-review"  = { description = "Needs code review", color = "fbca04" }
          "status/needs-testing" = { description = "Needs testing", color = "f9d0c4" }
          "status/ready"         = { description = "Ready for merge/deployment", color = "0e8a16" }
        }
      }

      # Component labels (repository-specific)
      component = {
        color_base = "5319e7" # Purple base
        labels = {
          "component/api"            = { description = "API related changes", color = "5319e7" }
          "component/frontend"       = { description = "Frontend/UI changes", color = "7057ff" }
          "component/backend"        = { description = "Backend/server changes", color = "8b74db" }
          "component/database"       = { description = "Database related changes", color = "a491d3" }
          "component/infrastructure" = { description = "Infrastructure changes", color = "beb7df" }
          "component/security"       = { description = "Security related changes", color = "d1c7e8" }
          "component/ci-cd"          = { description = "CI/CD pipeline changes", color = "e8dff5" }
        }
      }

      # Size labels (for estimation)
      size = {
        color_base = "e99695" # Light red base
        labels = {
          "size/xs" = { description = "Extra small change (< 1 day)", color = "0e8a16" }
          "size/s"  = { description = "Small change (1-2 days)", color = "5cbf60" }
          "size/m"  = { description = "Medium change (3-5 days)", color = "fbca04" }
          "size/l"  = { description = "Large change (1-2 weeks)", color = "f9d0c4" }
          "size/xl" = { description = "Extra large change (> 2 weeks)", color = "d73a4a" }
        }
      }

      # Environment labels
      environment = {
        color_base = "0052cc" # Dark blue base
        labels = {
          "env/development" = { description = "Development environment", color = "0052cc" }
          "env/staging"     = { description = "Staging environment", color = "1f77b4" }
          "env/production"  = { description = "Production environment", color = "d73a4a" }
          "env/testing"     = { description = "Testing environment", color = "17becf" }
        }
      }
    }
  }

  # Repository type specific labels
  repository_type_labels = {
    # Infrastructure repository labels
    infrastructure = {
      "terraform"         = { description = "Terraform/OpenTofu related", color = "623CE4" }
      "gcp"               = { description = "Google Cloud Platform", color = "4285F4" }
      "networking"        = { description = "Network infrastructure", color = "0066cc" }
      "security"          = { description = "Security infrastructure", color = "FF6B6B" }
      "monitoring"        = { description = "Monitoring and observability", color = "ff6600" }
      "cost-optimization" = { description = "Cost optimization changes", color = "00cc66" }
    }

    # API repository labels
    api = {
      "breaking-change" = { description = "Breaking API change", color = "d73a4a" }
      "versioning"      = { description = "API versioning", color = "0075ca" }
      "performance"     = { description = "Performance improvement", color = "0e8a16" }
      "authentication"  = { description = "Authentication/authorization", color = "ff9900" }
      "rate-limiting"   = { description = "Rate limiting changes", color = "fbca04" }
    }

    # Data repository labels
    data = {
      "etl"           = { description = "ETL pipeline changes", color = "1f77b4" }
      "bigquery"      = { description = "BigQuery related", color = "4285F4" }
      "data-quality"  = { description = "Data quality improvements", color = "0e8a16" }
      "schema-change" = { description = "Database schema change", color = "d73a4a" }
      "analytics"     = { description = "Analytics and reporting", color = "17becf" }
    }

    # Security repository labels
    security = {
      "vulnerability"    = { description = "Security vulnerability", color = "d73a4a" }
      "compliance"       = { description = "Compliance requirement", color = "0052cc" }
      "audit"            = { description = "Security audit", color = "fbca04" }
      "penetration-test" = { description = "Penetration testing", color = "ff6600" }
    }
  }

  # Environment-specific label modifications
  env_label_configs = {
    production = {
      # Add production-specific urgency
      "hotfix"      = { description = "Production hotfix", color = "d73a4a" }
      "rollback"    = { description = "Production rollback", color = "ff6600" }
      "post-mortem" = { description = "Post-mortem required", color = "8b0000" }
    }
    non-production = {
      # Development-friendly labels
      "experiment" = { description = "Experimental feature", color = "d876e3" }
      "spike"      = { description = "Investigation/spike work", color = "f9d0c4" }
      "prototype"  = { description = "Prototype implementation", color = "bfe5bf" }
    }
  }

  # Example of how to generate labels (move this logic to terragrunt.hcl files)
  # This is commented out because it references 'var' which isn't available in templates
}

# This template provides label configurations for different repository types and environments
# Use the locals in your terragrunt.hcl files to generate appropriate labels
#
# Example usage in terragrunt.hcl:
#
# locals {
#   labels_template = read_terragrunt_config(find_in_parent_folders("_common/templates/labels.hcl"))
#
#   # Generate labels for a specific repository type and environment
#   repository_labels = concat(
#     flatten([
#       for category, config in local.labels_template.locals.default_label_config.label_categories : [
#         for label_name, label_config in config.labels : {
#           name        = label_name
#           description = label_config.description
#           color       = label_config.color
#         }
#       ]
#     ]),
#     flatten([
#       for label_name, label_config in lookup(
#         local.labels_template.locals.repository_type_labels,
#         "api",  # or your repository type
#         {}
#       ) : {
#         name        = label_name
#         description = label_config.description
#         color       = label_config.color
#       }
#     ])
#   )
# }
#
# inputs = {
#   issue_labels = local.repository_labels
# }
