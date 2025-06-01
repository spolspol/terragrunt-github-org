# GitHub Organization Templates

This directory contains standardized templates for managing GitHub organization resources using Terragrunt. The templates follow best practices for consistency across infrastructure management.

## Available Templates

### Core Resource Templates

| Template | Purpose | Module |
|----------|---------|---------|
| `organization.hcl` | Organization settings and security | terraform-github-organization |
| `members.hcl` | Member and admin management | terraform-github-organization |
| `team.hcl` | Team management and access | terraform-github-team |
| `repository.hcl` | Repository configuration | **Enhanced terraform-github-repository** |

### Supporting Templates

| Template | Purpose | Usage |
|----------|---------|-------|
| `webhook.hcl` | Webhook and integration setup | Add to repository configs |
| `environment.hcl` | GitHub Environments (deployment) | Add to repository configs |
| `labels.hcl` | Issue and PR labels | Add to repository configs |

## Enhanced Repository Module

The repository template uses an enhanced `terraform-github-repository` module, which provides additional capabilities:

### Enhanced Features

- **Visibility Control**: Explicit `visibility` setting (private/public/internal)
- **Environment Management**: Native GitHub Environments support
- **Advanced Security**: Enhanced vulnerability alert configuration
- **Template Support**: Repository template creation and usage
- **Branch Management**: Advanced default branch configuration
- **Team Permissions**: Enhanced team access control

### Module Source

```hcl
terraform {
  source = "github.com/your-org/terraform-github-repository?ref=feature/environments"
}
```

### Key Differences from Standard Module

1. **Environment Support**: Native GitHub Environments with deployment rules
2. **Visibility Settings**: Explicit visibility control vs. private boolean
3. **Enhanced Security**: More granular vulnerability alert settings
4. **Template Features**: Repository template creation and cloning
5. **Team Integration**: Better team permission management

## Template Usage Patterns

### Basic Usage

Each template is designed to be included in your Terragrunt configurations:

```hcl
# Include template
include {
  path = find_in_parent_folders("_common/templates/repository.hcl")
}

# Override template defaults
inputs = {
  repository_type = "api"
  environment_type = "production"
  
  # Enhanced module features
  visibility = "private"
  vulnerability_alerts = true
  
  # Custom overrides
  description = "Custom repository description"
  topics = ["custom", "topics"]
}
```

### Environment-Aware Configuration

Templates automatically adjust based on environment:

```hcl
# Production: 2 reviewers, strict checks, enhanced security
# Non-production: 1 reviewer, basic checks, standard security
inputs = {
  environment_type = "production"  # or "non-production"
}
```

### Repository Type Templates

Different repository types have specialized configurations:

- `basic` - Default configuration with enhanced module features
- `infrastructure` - Terraform repos with enhanced security and visibility
- `api` - Application APIs with comprehensive testing and vulnerability alerts
- `data` - Data processing and analytics with team-based access
- `documentation` - Documentation repositories with internal visibility
- `security` - Security and compliance repos with maximum security

### Team Type Templates

Teams are configured based on their role:

- `admin` - Organization administrators
- `devops` - Infrastructure and platform management
- `developers` - Application development
- `data_engineering` - Data infrastructure
- `data_analysts` - Data consumers
- `security` - Security and compliance

## Template Variables

Templates accept these common variables:

### Environment Variables
- `environment_type` - "production" or "non-production"
- `repository_type` - Repository classification
- `visibility` - "private", "public", or "internal" (enhanced module)
- `vulnerability_alerts` - Enhanced security setting

### Enhanced Module Variables
- `template` - Source template repository name
- `template_owner` - Template repository owner
- `default_branch` - Default branch name
- `environments` - GitHub Environments configuration

### Override Variables
- `team_definitions` - Team type mappings
- `team_overrides` - Team-specific overrides
- `additional_labels` - Extra issue labels
- `environment_variables` - Environment variables
- `environment_secrets` - Environment secrets

## Example Configurations

### Infrastructure Repository (Enhanced)

```hcl
include {
  path = find_in_parent_folders("_common/templates/repository.hcl")
}

inputs = {
  repository_type = "infrastructure"
  environment_type = "production"
  visibility = "private"
  
  description = "Infrastructure managed by Terragrunt"
  topics = ["infrastructure", "terraform", "automation"]
  
  # Enhanced security settings
  vulnerability_alerts = true
  
  # Infrastructure-specific environments
  environment_definitions = {
    "dev" = {
      environment_type = "development"
      purpose = "infrastructure"
      overrides = {
        variables = {
          PROJECT_ID = "your-dev-project"
          ENVIRONMENT = "dev"
        }
      }
    }
  }
}
```

### API Repository (Enhanced)

```hcl
include {
  path = find_in_parent_folders("_common/templates/repository.hcl")
}

inputs = {
  repository_type = "api"
  environment_type = "production"
  visibility = "private"
  
  description = "Your Organization API"
  
  # Enhanced security for production API
  vulnerability_alerts = true
  
  # API-specific webhooks
  webhook_definitions = {
    "slack_notifications" = {
      url = "https://hooks.slack.com/services/..."
      webhook_type = "slack"
    }
  }
  
  # Deployment environments with enhanced module
  environment_definitions = {
    "production" = {
      environment_type = "production"
      purpose = "application"
      overrides = {
        variables = {
          NODE_ENV = "production"
          APP_NAME = "your-api"
        }
      }
    }
  }
}
```

### Team Configuration

```hcl
include {
  path = find_in_parent_folders("_common/templates/team.hcl")
}

inputs = {
  environment_type = "production"
  
  # Define teams by type
  team_definitions = {
    "admins" = "admin"
    "devops" = "devops"
    "developers" = "developers"
    "data-engineering" = "data_engineering"
    "data-analysts" = "data_analysts"
  }
  
  # Team-specific overrides
  team_overrides = {
    "developers" = {
      members = ["dev1", "dev2", "dev3"]
    }
  }
}
```

## Enhanced Module Benefits

### Security Improvements
- Explicit visibility control prevents accidental exposure
- Enhanced vulnerability alert configuration
- Better security defaults for different repository types

### Environment Management
- Native GitHub Environments support
- Deployment rules and protection
- Environment-specific variables and secrets

### Repository Templates
- Create repositories from templates
- Standardize repository structure
- Consistent initialization across repositories

### Team Integration
- Better team permission management
- Granular access control
- Role-based repository access

## Best Practices

1. **Always specify visibility** - Use explicit visibility setting instead of private boolean
2. **Enable vulnerability alerts** - For all production repositories
3. **Use appropriate repository_type** - Gets enhanced defaults for your use case
4. **Leverage environments** - For deployment workflows and protection
5. **Follow security defaults** - Templates provide enhanced security configurations

## Migration from Standard Module

When migrating from the standard terraform-github-repository module:

1. **Update module source** to your enhanced terraform-github-repository fork
2. **Replace `private` with `visibility`** setting
3. **Enable `vulnerability_alerts`** for enhanced security
4. **Configure environments** if using deployment workflows
5. **Review team permissions** for enhanced access control

## Template Dependencies

Templates may reference:
- `_common/common.hcl` - Module versions and global settings
- Parent directory configurations (account.hcl, env.hcl)
- Environment variables (`ORG_GITHUB_TOKEN`)
- Enhanced module features from your terraform-github-repository fork

## Extending Templates

To add new repository types or team types:

1. Add configuration to the appropriate template
2. Leverage enhanced module features
3. Update this README with usage examples
4. Test with a non-production environment
5. Document any new variables or patterns
