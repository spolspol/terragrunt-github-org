### Workflow Status

[![Terragrunt PR Workflow](https://github.com/example-org/terragrunt-github-org/actions/workflows/terragrunt-pr.yml/badge.svg)](https://github.com/example-org/terragrunt-github-org/actions/workflows/terragrunt-pr.yml)
[![Terragrunt Apply Workflow](https://github.com/example-org/terragrunt-github-org/actions/workflows/terragrunt-apply.yml/badge.svg)](https://github.com/example-org/terragrunt-github-org/actions/workflows/terragrunt-apply.yml)

# GitHub Organization Management with Terragrunt and OpenTofu

This repository provides a **Terragrunt** and **OpenTofu**-based scaffolding to manage GitHub Organizations, including org settings, members, teams, and repositories, using [Mineiros GitHub modules](https://github.com/mineiros-io).

The infrastructure is managed using Terragrunt for configuration organization and OpenTofu as the underlying Infrastructure-as-Code engine. This combination provides a powerful, open-source solution for managing GitHub organizations at scale.

The scaffolding follows best practices from [Terragrunt Infrastructure Live Example](https://github.com/gruntwork-io/terragrunt-infrastructure-live-example).

## Table of Contents

- [Workflow Status](#workflow-status)
- [Features Overview](#features-overview)
  - [Automated Organization Configuration](#automated-organization-configuration)
  - [Advanced Security Controls](#advanced-security-controls)
  - [Granular Access Management](#granular-access-management)
  - [Repository Standardization](#repository-standardization)
  - [Compliance and Governance](#compliance-and-governance)
  - [Automated Workflows](#automated-workflows)
- [Folder Structure](#folder-structure)
- [How Configuration Works](#how-configuration-works)
- [Creating New Resources Using Templates](#creating-new-resources-using-templates)
  - [Using Existing Resources as Templates](#using-existing-resources-as-templates)
  - [Key Points When Using Templates](#key-points-when-using-templates)
- [Example Configurations](#example-configurations)
  - [Organization Variables](#organization-variables-liveorg-nameorg-hcl)
  - [Organization Settings](#organization-settings-liveorg-nameorg-settingsterragrunthcl)
  - [Member Management](#member-management-liveorg-namemembersterragrunthcl)
  - [Repository Configuration](#repository-configuration-liveorg-namerepositoriesexample-repoterragrunthcl)
  - [Teams Configuration](#teams-configuration)
- [Getting Started](#getting-started)
- [GitHub Actions Workflows](#github-actions-workflows)
  - [Workflow Behavior](#workflow-behavior)
  - [Available Workflows](#available-workflows)
  - [Workflow Requirements](#workflow-requirements)
  - [Best Practices](#best-practices)
- [References](#references)

## Features Overview

This project provides comprehensive GitHub organization management through Infrastructure as Code, offering:

### Automated Organization Configuration
- Complete organization profile management including name, description, and contact details
- Hierarchical configuration inheritance for consistent settings across teams and repositories
- Version-controlled organization settings for audit and compliance

### Advanced Security Controls
- Automated security policy enforcement across repositories
- Dependabot vulnerability scanning and alerts
- Secret scanning with push protection
- Dependency graph analysis
- Advanced security features for all new repositories

### Granular Access Management
- Role-based access control through teams
- Centralized member and admin management
- Automated onboarding/offboarding workflows
- Configurable repository permissions and visibility settings

### Repository Standardization
- Consistent repository settings and configurations
- Automated branch protection rules including:
  - Required status checks
  - Required reviews
  - Signed commits
  - Linear history enforcement
- Standardized merge strategies and settings

### Compliance and Governance
- Enforced commit message conventions
- Required code owner reviews
- Mandatory review thread resolution
- Audit trails through Git history
- Automated policy enforcement

### Automated Workflows
- GitHub Actions-based automation for infrastructure changes
- Automated PR validation and planning
- Parallel processing of changes for efficient updates
- Automated state management and locking
- Change detection and targeted updates
- Integration with organization-wide security policies

The infrastructure is managed through Terragrunt configurations, providing a scalable and maintainable approach to GitHub organization management. All settings are defined as code, enabling version control, peer review, and automated validation of changes.

---

## Folder Structure

```
.
├── .github/                        # GitHub Actions workflows and templates
├── live/                           # Terragrunt configuration root
│   ├── common.hcl                  # Root-level shared variables
│   ├── root.hcl                    # Root config: backend, provider
│   └── <org-name>/                 # Organization-specific configuration
│       ├── org.hcl                 # Organization-level shared variables
│       ├── .gitignore              # Organization-specific gitignore
│       ├── org-settings/           # Organization settings
│       │   └── terragrunt.hcl      # Organization-wide settings
│       ├── members/                # Member management
│       │   └── terragrunt.hcl      # Member management configuration
│       ├── teams/                  # Team management
│       │   ├── teams.hcl           # Common team settings and variables
│       │   └── example-team/       # Example team configuration
│       │       └── terragrunt.hcl  # Team-specific settings
│       └── repositories/           # Repository management
│           ├── repos.hcl           # Repository-level shared variables
│           └── <repo-name>/        # Individual repository configurations
│               └── terragrunt.hcl  # Repository-specific settings
└── README.md                       # Project documentation
```

---

## How Configuration Works

- **Shared Variables:**
  - `live/common.hcl` and `live/<org-name>/org.hcl` provide shared variables (e.g., `ORG_GITHUB_TOKEN`, organization name) for all modules.
  - Most repository configs use a `locals` block to load these shared variables and merge them into their `inputs`.
- **Dynamic Naming:**
  - Repository names are set dynamically using `${basename(get_terragrunt_dir())}` for consistency.
- **Module Sources:**
  - Organization: [mineiros-io/terraform-github-organization](https://github.com/mineiros-io/terraform-github-organization)
  - Repositories: [mineiros-io/terraform-github-repository](https://github.com/mineiros-io/terraform-github-repository)
  - Teams: [mineiros-io/terraform-github-team](https://github.com/mineiros-io/terraform-github-team)

---

## Creating New Resources Using Templates

### Using Existing Resources as Templates

1. **Creating a New Repository:**
   ```bash
   # Navigate to the repositories directory
   cd live/<org-name>/repositories
   
   # Copy an existing repository folder as a template
   cp -r example-repo new-repo-name
   
   # Edit the new repository's configuration
   cd new-repo-name
   vim terragrunt.hcl
   ```

### Key Points When Using Templates:
- Always update the name in the new configuration (it will default to the folder name)
- Review and update all collaborators and permissions
- Update descriptions and other specific settings
- Remove any environment-specific configurations that don't apply to your new resource

---

## Example Configurations

### Root Backend and Provider (`live/root.hcl`)

By default, this template uses a local backend for state storage. However, for production environments, it's recommended to use a remote backend like AWS S3 or Google Cloud Storage. Here are examples for different backend configurations:

#### Local Backend (Default)
```hcl
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "local" {
    path = "${get_terragrunt_dir()}/terraform.tfstate"
  }
}
EOF
}
```

#### Google Cloud Storage Backend
```hcl
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "gcs" {
    bucket   = get_env("TF_STATE_BUCKET")
    prefix   = "github-org/${path_relative_to_include()}/terraform.tfstate"
    project  = "your-gcp-project"
  }
}
EOF
}
```

Required environment variables for GCS:
- `TF_STATE_BUCKET`: Your GCS bucket name
- `GOOGLE_CREDENTIALS`: Path to your GCP service account key file

#### AWS S3 Backend
```hcl
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "github-org/${path_relative_to_include()}/terraform.tfstate"
    region         = "us-west-2"  # Change to your desired region
    encrypt        = true
    dynamodb_table = "terraform-lock-table"  # Optional: for state locking
  }
}
EOF
}
```

Required environment variables for AWS:
- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
- `AWS_REGION`: Your AWS region (if different from the one in configuration)

### Provider Configuration
```hcl
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "github" {
  owner = "<your-org-name>"
}
EOF
}
```

### Organization Variables (`live/<org-name>/org.hcl`)
```hcl
locals {
  # Organization settings
  org_name        = get_env("GITHUB_OWNER")
  org_description = "Managed by Terragrunt"
  org_website     = "https://example.com"
  org_location    = "Global"
  org_email       = "admin@example.com"
  
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
```

### Organization Settings (`live/<org-name>/org-settings/terragrunt.hcl`)
```hcl
include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  org_vars    = read_terragrunt_config(find_in_parent_folders("org.hcl"))
  
  # Get organization name from parent folder
  org_name = basename(dirname(get_terragrunt_dir()))
}

terraform {
  source = "github.com/vmvarela/terraform-github-org?ref=v0.2.0"
}

inputs = merge(
  local.common_vars.locals,
  local.org_vars.locals,
  {
    settings = {
      billing_email = local.org_vars.locals.org_email
      name          = local.org_name
      description   = "${local.org_name} organization managed by Terragrunt"
      blog          = local.org_vars.locals.org_website
      location      = local.org_vars.locals.org_location
      
      # Repository permissions
      default_repository_permission = "read"
      members_can_create_repositories = true
      members_can_create_private_repositories = true
      members_can_create_public_repositories = false
      
      # Security settings
      web_commit_signoff_required = true
      advanced_security_enabled_for_new_repositories = true
      dependabot_alerts_enabled_for_new_repositories = true
      dependency_graph_enabled_for_new_repositories = true
      secret_scanning_enabled_for_new_repositories = true
      secret_scanning_push_protection_enabled_for_new_repositories = true
    }
  }
)
```

### Member Management (`live/<org-name>/members/terragrunt.hcl`)
```hcl
include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  org_vars    = read_terragrunt_config(find_in_parent_folders("org.hcl"))
  
  # Get organization name from parent folder
  org_name = basename(dirname(get_terragrunt_dir()))
}

terraform {
  source = "github.com/mineiros-io/terraform-github-organization?ref=v0.9.0"
}

inputs = merge(
  local.common_vars.locals,
  local.org_vars.locals,
  {
    # Member management - Replace with actual members
    members = [
      "example-member-1",
      "example-member-2"
    ]

    # Organization Admins - Replace with actual admins
    admins = [
      "example-admin-1"
    ]

    # All Members Team
    all_members_team_name       = "${local.org_name}-all-members"
    all_members_team_visibility = "secret"
    catch_non_existing_members  = false

    # Blocked Users (if any)
    blocked_users = []
  }
)
```

### Repository Configuration (`live/<org-name>/repositories/example-repo/terragrunt.hcl`)
```hcl
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
```

Key features of the configuration:
1. All configurations use `merge` to combine settings from multiple sources
2. Dynamic naming using `basename` functions
3. Hierarchical configuration with shared variables
4. Consistent use of latest module versions
5. Clear separation of concerns between different configuration files
6. Extensive use of defaults and inheritance for consistent settings

### Teams Example (`live/<org-name>/teams/example-team/terragrunt.hcl`)
```hcl
include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  org_vars    = read_terragrunt_config(find_in_parent_folders("org.hcl"))
  team_vars   = read_terragrunt_config(find_in_parent_folders("teams.hcl"))
}

terraform {
  source = "github.com/mineiros-io/terraform-github-team?ref=v0.9.0"
}

inputs = merge(
  local.common_vars.inputs,
  local.team_vars.inputs.team_settings,
  {
    name        = "${basename(get_terragrunt_dir())}"
    description = "Example Team"
    members     = []
    maintainers = []
  }
)
```

### Common Team Settings (`live/<org-name>/teams/teams.hcl`)
```hcl
locals {
  # Common variables for all teams
  common_team_settings = {
    privacy = "closed"  # Default privacy setting for all teams
    
    # Default team permissions
    base_permissions = "pull"  # Read-only access by default
    
    # Common maintainers across all teams (optional)
    default_maintainers = []
    
    # Common team settings
    create_default_maintainer = false
    parent_team_id           = null
  }
}

# Export the common team settings to be used by child terragrunt configurations
inputs = {
  team_settings = local.common_team_settings
}
```

The teams configuration follows a hierarchical structure where:
1. Common settings are defined in `teams.hcl`
2. Each team inherits these settings through the `team_vars` local variable
3. Team-specific settings can override or extend the common settings
4. Team name is automatically set from the directory name using `${basename(get_terragrunt_dir())}`

---

## Getting Started

1. Clone this repository
2. Set up required environment variables:
   ```bash
   export ORG_GITHUB_TOKEN="your-github-token"
   ```
3. Initialize and apply the Terragrunt configurations:
   ```bash
   cd live/<org-name>
   terragrunt run-all init
   terragrunt run-all plan
   terragrunt run-all apply
   ```

---

## GitHub Actions Workflows

This repository includes two GitHub Actions workflows for managing Terragrunt operations:

### Workflow Behavior

1. **Change Detection:**
   - Workflows only trigger on changes in `live/<org-name>/` directory
   - Changes must be at least one level deep (e.g., `live/<org-name>/members/...`)

2. **Matrix Strategy:**
   - Changes in multiple directories are processed in parallel
   - If one directory fails, other directories continue processing (`fail-fast: false`)
   - Removed directories are automatically excluded from processing

### Available Workflows

1. **Terragrunt PR Checks** (`.github/workflows/terragrunt-pr.yml`):
   - Runs on pull requests
   - Performs formatting checks
   - Generates and comments Terragrunt plans
   - Helps review infrastructure changes before merging

2. **Terragrunt Apply** (`.github/workflows/terragrunt-apply.yml`):
   - Runs on merges to main branch
   - Applies approved changes automatically
   - Processes changes in parallel for efficiency

### Workflow Requirements

- `ORG_GITHUB_TOKEN`: GitHub token with organization admin permissions
- Backend-specific credentials (choose one based on your backend):
  - Local: No additional credentials needed
  - GCS: `GOOGLE_CREDENTIALS` for Google Cloud credentials
  - AWS: `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` for AWS credentials
- Terragrunt version: 0.79.0
- OpenTofu version: 1.9.1

### Best Practices

1. **Making Changes:**
   - Always create a new branch for changes
   - Make changes in the appropriate subdirectory
   - Test changes using the PR workflow before merging

2. **Directory Structure:**
   - Keep changes organized in their respective directories
   - Use existing configurations as templates
   - Follow the established naming conventions

3. **Workflow Usage:**
   - Review PR checks before merging
   - Monitor apply workflow for successful execution
   - Check workflow logs if any issues occur

---

## References
- [Terragrunt Infrastructure Live Example](https://github.com/gruntwork-io/terragrunt-infrastructure-live-example)
- [OpenTofu](https://github.com/opentofu/opentofu)
- [Mineiros GitHub Team Module](https://github.com/mineiros-io/terraform-github-team)
- [Mineiros GitHub Repository Module](https://github.com/mineiros-io/terraform-github-repository)
- [Mineiros GitHub Teams Module](https://github.com/mineiros-io/terraform-github-teams)
- [gruntwork-io/terragrunt-action (GitHub Action)](https://github.com/gruntwork-io/terragrunt-action)
