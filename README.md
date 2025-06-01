### Workflow Status

[![Terragrunt PR Workflow](https://github.com/your-org/tg-github-org/actions/workflows/terragrunt-pr-orchestrator.yml/badge.svg)](https://github.com/your-org/tg-github-org/actions/workflows/terragrunt-pr-orchestrator.yml)
[![Terragrunt Apply Workflow](https://github.com/your-org/tg-github-org/actions/workflows/terragrunt-apply-orchestrator.yml/badge.svg)](https://github.com/your-org/tg-github-org/actions/workflows/terragrunt-apply-orchestrator.yml)

# GitHub Organization Management

This repository provides a **Terragrunt**-based scaffolding to manage your **GitHub Organization**, including org settings, members, teams, and repositories, using [Mineiros GitHub modules](https://github.com/mineiros-io).

The scaffolding follows best practices from [Terragrunt Infrastructure Live Example](https://github.com/gruntwork-io/terragrunt-infrastructure-live-example).

## Table of Contents

- [Organization Profile](#organization-profile)
- [Getting Started](#getting-started)
- [Organization Settings](#organization-settings)
  - [Member Management](#member-management)
  - [Repository Permissions](#repository-permissions)
  - [Security Settings](#security-settings)
  - [Branch Protection Rules](#branch-protection-rules)
- [Folder Structure](#folder-structure)
- [How Configuration Works](#how-configuration-works)
- [Creating New Resources Using Templates](#creating-new-resources-using-templates)
  - [Using Existing Resources as Templates](#using-existing-resources-as-templates)
  - [Key Points When Using Templates](#key-points-when-using-templates)
- [Example Configurations](#example-configurations)
  - [Root Backend and Provider](#root-backend-and-provider-liveroothcl)
  - [Shared Variables](#shared-variables-livecommonhcl)
  - [Organization Settings Example](#organization-settings-example-liveorg-nameorg-settingsterragrunthcl)
  - [Member Management Example](#member-management-example-liveorg-namemembersterragrunthcl)
  - [Repository Example](#repository-example-liveorg-namerepositoriesexample-repoterragrunthcl)
  - [Teams Example](#teams-example-liveorg-nameteamsterragrunthcl)
- [GitHub Actions Workflows](#github-actions-workflows)
  - [Workflow Behavior](#workflow-behavior)
  - [Available Workflows](#available-workflows)
  - [Workflow Requirements](#workflow-requirements)
  - [Best Practices](#best-practices)
- [References](#references)

## Organization Profile

Configure your organization profile in `live/org.hcl`:

- **Name**: Your Organization Name
- **Description**: Managed by Terragrunt with OpenTofu
- **Company**: Your Company Name
- **Location**: Your Location
- **Website**: Your organization website

## Getting Started

📋 **For detailed configuration instructions, see [docs/CONFIGURATION_GUIDE.md](docs/CONFIGURATION_GUIDE.md)**

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-org/tg-github-org.git
   cd tg-github-org
   ```

2. **Configure your organization settings:**
   ```bash
   # Edit organization configuration
   vim live/org.hcl
   
   # Update with your organization details:
   # - owner: your GitHub organization name
   # - org_name: display name
   # - org_description: organization description
   # - company_name: your company name
   # - website_url: your website
   # - billing_email: admin email
   ```

3. **Set up commit signing (recommended):**
   ```bash
   # Configure GPG commit signing for enhanced security
   # See docs/COMMIT_SIGNING.md for detailed instructions
   ```
   📋 **For detailed GPG setup instructions, see [docs/COMMIT_SIGNING.md](docs/COMMIT_SIGNING.md)**

4. **Set up environment variables:**
   ```bash
   export ORG_GITHUB_TOKEN="your_github_token_here"
   # Optional: Cloud credentials for state storage
   export TF_GOOGLE_CREDENTIALS="path_to_service_account.json"
   ```

5. **Configure backend storage:**
   ```bash
   # Edit root.hcl to configure your state backend
   vim root.hcl
   
   # Update the backend configuration with your storage details
   ```

6. **Initialize and apply organization settings:**
   ```bash
   # Start with organization settings
   cd live/org
   terragrunt init
   terragrunt plan
   terragrunt apply
   
   # Then members
   cd ../members
   terragrunt init && terragrunt apply
   
   # Then teams (example)
   cd ../teams/admins
   terragrunt init && terragrunt apply
   
   # Finally repositories (example)
   cd ../../repositories/web-app
   terragrunt init && terragrunt apply
   ```

7. **Use GitHub Actions for ongoing management:**
   - Create pull requests for changes
   - Review validation results in PR comments
   - Merge to main for automatic deployment

---

## Organization Settings

The organization is configured with the following settings:

### Member Management
- Centralized member management in `members/terragrunt.hcl`
- All-members team with secret visibility
- Admin team management
- Blocked users list

### Repository Permissions
- Members can create repositories
- Members can create private repositories
- Public repository creation is restricted
- Default repository permission is set to "read"

### Security Settings
- Advanced security features enabled for new repositories
- Dependabot alerts enabled
- Dependency graph enabled
- Secret scanning enabled with push protection
- Dependabot security updates disabled for new repositories

### Branch Protection Rules
- Required status checks for CI
- Linear history required
- Conventional commit format enforced:
  - `feat:` - New features
  - `fix:` - Bug fixes
  - `docs:` - Documentation changes
  - `style:` - Formatting changes
  - `refactor:` - Code refactoring
  - `test:` - Adding tests
  - `chore:` - Maintenance tasks
- Required code owner review
- Required review thread resolution

For detailed settings, please refer to the configuration in:
- `live/org/terragrunt.hcl` - Organization-wide settings
- `live/members/terragrunt.hcl` - Member management

---

## Folder Structure

```
.
├── .github/                        # GitHub Actions workflows and templates
│   └── workflows/                  # GitHub Actions workflow files
│       ├── common-env.yml          # Centralized environment variables
│       ├── terragrunt-pr-orchestrator.yml       # PR validation orchestrator
│       ├── terragrunt-apply-orchestrator.yml    # Apply deployment orchestrator
│       └── terragrunt-unified-reusable.yml      # Reusable workflow template
├── _common/                        # Common configurations and templates
│   ├── common.hcl                  # Module versions and shared settings
│   └── templates/                  # Reusable templates
│       ├── repository.hcl          # Repository template with type variants
│       ├── team.hcl                # Team management template
│       ├── members.hcl             # Members management template
│       └── organization.hcl        # Organization settings template
├── docs/                           # Project documentation
│   └── ...                        # Additional documentation files
├── live/                           # Live Terragrunt configurations
│   ├── org.hcl                     # Organization-level shared variables
│   ├── org/                        # Organization settings
│   │   └── terragrunt.hcl          # Organization-wide settings
│   ├── members/                    # Member management
│   │   └── terragrunt.hcl          # Member management configuration
│   ├── teams/                      # Team management (individual team folders)
│   │   └── <team-name>/            # Additional teams as needed
│   │       └── terragrunt.hcl      # Team configuration
│   └── repositories/               # Repository management
│       ├── repos.hcl               # Repository-level shared variables
│       ├── <repo-name>/            # Individual repository configurations
│       │   └── terragrunt.hcl      # Repository settings
├── scripts/                        # Utility scripts
│   ├── terragrunt-format.sh        # Pre-commit format script
│   └── terragrunt-format-check.sh  # Pre-commit format check script
├── root.hcl                        # Root configuration with backend and provider
└── README.md                       # Project documentation
```

---

## How Configuration Works

### Template-Based Architecture

The configuration uses a sophisticated template system for consistency and maintainability:

- **Common Configuration**: `_common/common.hcl` provides module versions and shared settings
- **Template System**: `_common/templates/` contains reusable configuration patterns
- **Hierarchical Configuration**: Each resource inherits from templates and overrides as needed

### Configuration Hierarchy

1. **Root Level**: `root.hcl` provides backend and provider configuration  
2. **Common Level**: `_common/common.hcl` provides module versions and shared settings
3. **Organization Level**: `live/org.hcl` provides organization-wide variables
4. **Resource Level**: Individual `terragrunt.hcl` files inherit and merge all parent settings

### Key Features

- **Dynamic Naming**: Repository names automatically derived from directory names using `basename(get_terragrunt_dir())`
- **Template Inheritance**: Resources use templates from `_common/templates/` for consistent configuration
- **Unified Settings**: Production/non-production split removed in favor of unified organization-grade settings
- **Module Versions**: Centrally managed in `_common/common.hcl`

### Core Modules

- **Organization**: [mineiros-io/terraform-github-organization](https://github.com/mineiros-io/terraform-github-organization) v0.9.0
- **Repositories**: [mineiros-io/terraform-github-repository](https://github.com/mineiros-io/terraform-github-repository) v0.18.0 (or enhanced fork with environment support)
- **Teams**: [mineiros-io/terraform-github-team](https://github.com/mineiros-io/terraform-github-team) v0.9.0

---

## Creating New Resources Using Templates

### Using Existing Resources as Templates

1. **Creating a New Repository:**
   ```bash
   # Navigate to the repositories directory
   cd live/repositories
   
   # Copy an existing repository folder as a template
   cp -r web-app new-repo-name
   
   # Edit the new repository's configuration
   cd new-repo-name
   vim terragrunt.hcl
   ```

2. **Creating a New Team:**
   ```bash
   # Navigate to the teams directory
   cd live/teams
   
   # Copy an existing team as a template
   cp -r admins new-team-name
   
   # Edit the new team's configuration
   cd new-team-name
   vim terragrunt.hcl
   ```

### Key Points When Using Templates:
- Always update the name in the new configuration (it will default to the folder name)
- Review and update all collaborators and permissions
- Update descriptions and other specific settings
- Remove any environment-specific configurations that don't apply to your new resource

---

## Example Configurations

### Root Configuration (`root.hcl`)
```hcl
locals {
  # Read organization variables
  org_vars = read_terragrunt_config(find_in_parent_folders("live/org.hcl"))
}

# Backend configuration for GCS
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "gcs" {
    bucket = "your-terraform-state-bucket"
    prefix = "github-org/${path_relative_to_include()}/terraform.tfstate"
  }
}
EOF
}

# Provider configuration with dynamic values
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "github" {
  owner = "${local.org_vars.locals.owner}"
  token = "${local.org_vars.locals.github_token}"
}
EOF
}
```

### Organization Variables (`live/org.hcl`)
```hcl
locals {
  # Organization configuration
  owner         = "your-organization"
  github_token  = get_env("ORG_GITHUB_TOKEN")
  
  # Common labels for all resources
  common_labels = {
    terraform_managed = "true"
    repository        = "tg-github-org"
    organization      = "your-organization"
  }
}
```

### Organization Settings Example (`live/org/terragrunt.hcl`)
```hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "organization" {
  path = "${get_terragrunt_dir()}/../../_common/templates/organization.hcl"
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("_common/common.hcl"))
  org_vars    = read_terragrunt_config(find_in_parent_folders("org.hcl"))
}

inputs = merge(
  local.common_vars.locals.common_labels,
  local.org_vars.locals.common_labels,
  {
    # Organization settings from template with overrides
    billing_email = "admin@your-organization.com"
    name          = "Your Organization"
    description   = "Managed by Terragrunt with OpenTofu"
    company       = "Your Company Ltd"
    location      = "Your Location"
    blog          = "https://your-organization.com/"
  }
)
```

### Member Management Example (`live/members/terragrunt.hcl`)
```hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "members" {
  path = "${get_terragrunt_dir()}/../../_common/templates/members.hcl"
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("_common/common.hcl"))
  org_vars    = read_terragrunt_config(find_in_parent_folders("org.hcl"))
}

inputs = merge(
  local.common_vars.locals.common_labels,
  local.org_vars.locals.common_labels,
  {
    # Member management
    members = [
      "user1",
      "user2",
      "user3"
    ]

    # Organization Admins
    admins = [
      "admin-user1", 
      "admin-user2"
    ]

    # All Members Team configuration
    all_members_team_name       = "all-members"
    all_members_team_visibility = "secret"
    catch_non_existing_members  = false

    # Blocked Users (if any)
    blocked_users = []
  }
)
```

### Repository Example (`live/repositories/<repo-name>/terragrunt.hcl`)

The repository configuration uses a template-based pattern with hierarchical configuration:
- **Template inheritance** from `_common/templates/repository.hcl`
- **Shared repository settings** from `repos.hcl`
- **Repository-specific overrides** in individual `terragrunt.hcl` files
- **Automatic naming** from directory name

**Example Configuration:**

`live/repositories/<repo-name>/terragrunt.hcl`:
```hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "repository" {
  path = "${get_terragrunt_dir()}/../../../_common/templates/repository.hcl"
}

locals {
  common_vars     = read_terragrunt_config(find_in_parent_folders("_common/common.hcl"))
  org_vars        = read_terragrunt_config(find_in_parent_folders("org.hcl"))
  repo_vars       = read_terragrunt_config(find_in_parent_folders("repos.hcl"))
  repository_name = basename(get_terragrunt_dir())
}

inputs = merge(
  local.common_vars.locals.common_labels,
  local.org_vars.locals.common_labels,
  local.repo_vars.locals.default_repository_settings,
  {
    name        = local.repository_name
    description = "Application repository with custom configuration"
    topics      = ["your-organization", "managed-by-terragrunt", "application"]
    
    # Team access (using template defaults with overrides)
    push_teams     = ["developers", "devops"]
    maintain_teams = ["lead-developers"]
    
    # Repository type configuration
    gitignore_template = "Node"
    
    # Branch protection (inherits from template)
    branch_protections_v4 = [
      {
        pattern                         = "main"
        required_pull_request_reviews = {
          required_approving_review_count = 2  # Override template default
        }
      }
    ]
  }
)
```

### Teams Example (`live/teams/<team-name>/terragrunt.hcl`)

Teams are now managed individually with each team having its own directory:

```hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "team" {
  path = "${get_terragrunt_dir()}/../../../_common/templates/team.hcl"
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("_common/common.hcl"))
  org_vars    = read_terragrunt_config(find_in_parent_folders("org.hcl"))
  team_name   = basename(get_terragrunt_dir())
}

inputs = merge(
  local.common_vars.locals.common_labels,
  local.org_vars.locals.common_labels,
  {
    name        = local.team_name
    description = "Development Team"
    privacy     = "closed"
    
    # Team members and maintainers
    members     = ["developer1", "developer2", "developer3"]
    maintainers = ["tech-lead"]
    
    # Repository permissions
    repositories = [
      {
        name       = "web-app"
        permission = "push"
      },
      {
        name       = "api-service"
        permission = "push"
      }
    ]
  }
)
```

**Example Teams Structure:**
- `live/teams/admins/` - Organization administrators
- `live/teams/developers/` - Application developers
- `live/teams/devops/` - DevOps and infrastructure team  
- `live/teams/data-team/` - Data and analytics team

---

## GitHub Actions Workflows

This repository uses an advanced orchestrated workflow system for managing GitHub organization infrastructure:

### Workflow Architecture

The system uses a **unified reusable workflow** pattern with **orchestrator workflows** that manage multiple resource types in proper dependency order:

1. **Resource Dependencies:** Organization Settings → Members → Teams → Repositories
2. **Parallel Execution:** Resources are processed in parallel within dependency constraints
3. **Failure Handling:** Early failure detection prevents cascading issues
4. **Manual Execution:** Apply workflow supports manual execution with resource targeting

### Available Workflows

1. **PR Orchestrator** (`.github/workflows/terragrunt-pr-orchestrator.yml`):
   - Triggers on pull requests affecting `live/**`, `_common/**`, or `root.hcl`
   - Validates all affected resources in dependency order
   - Posts detailed validation results as PR comments
   - Two-step validation: Format Check (blocking) → Plan Validation

2. **Apply Orchestrator** (`.github/workflows/terragrunt-apply-orchestrator.yml`):
   - Triggers on pushes to main branch
   - **Manual execution supported** with resource targeting options:
     - `auto-detect` (default) - Detects changes automatically
     - `org-settings` - Apply only organization settings  
     - `members` - Apply only member management
     - `teams` - Apply only team management
     - `repositories` - Apply only repository management
     - `all` - Apply all resources
   - Deploys changes in dependency order with comprehensive reporting

3. **Unified Reusable Workflow** (`.github/workflows/terragrunt-unified-reusable.yml`):
   - Shared workflow used by orchestrators
   - Handles both validation and apply operations
   - Matrix strategy for parallel resource processing
   - Integrated error handling and reporting

### Centralized Environment Management

All workflows use centralized environment variables from `.github/workflows/common-env.yml`:

- **Terragrunt Version**: 0.80.4
- **OpenTofu Version**: 1.10.0-beta2  
- **Experimental Features**: Enabled for enhanced CLI experience
- **Cloud Integration**: Project and region configuration (configurable for your cloud provider)

### Workflow Requirements

- `ORG_GITHUB_TOKEN`: GitHub token with organization admin permissions
- Backend credentials: Configure based on your chosen backend (GCS, S3, Azure, etc.)
- **Environment Protection**: Production deployments require manual approval

### Workflow Customization

The workflows are designed to be generic and work with any organization. Key customization points:

- **Cloud Configuration**: Update `GCP_PROJECT_ID` and `GCP_REGION` in `.github/workflows/common-env.yml`
- **Tool Versions**: Centrally managed in `common-env.yml` for consistency
- **Environment Protection**: Configure `approval-required` environment in repository settings
- **Backend Integration**: Supports GCS, S3, and Azure backends with appropriate authentication

📋 **For detailed workflow configuration, see [docs/CONFIGURATION_GUIDE.md](docs/CONFIGURATION_GUIDE.md#workflow-configuration)**

### Best Practices

1. **Working with Repositories**

   - **Security & Authentication:**
     - **Set up GPG commit signing** for verified commits (see [docs/COMMIT_SIGNING.md](docs/COMMIT_SIGNING.md))
     - Use strong authentication methods for GitHub access
     - Follow the principle of least privilege for repository permissions

   - **Branching:**
     - Always create a new branch for each change, using a descriptive name (e.g., `feature/xyz`, `fix/bug-123`, `hotfix/security-patch`).
     - Keep branches focused on a single purpose or feature.

   - **Making Changes:**
     - Make changes in the appropriate subdirectory for the repository or resource.
     - Use existing configurations as templates when adding new resources.
     - Follow established naming conventions for files and branches.

   - **Pull Request (PR) Approval Process:**
     1. **Open a Pull Request:**
        - Push your branch to the remote repository and open a PR against the `main` branch.
        - Provide a clear title and description of the changes.
     2. **Automated Checks:**
        - The PR workflow will run automated checks (formatting, Terragrunt plan, etc.).
        - Ensure all status checks pass before requesting review.
     3. **Code Review:**
        - At least one team member (or a required number, as set in branch protection rules) must review and approve the PR.
        - Address any feedback or requested changes.
     4. **Approval and Merge:**
        - Once approved and all checks pass, the PR can be merged into `main`.
        - Use "Squash and merge" or "Rebase and merge" as preferred by your team.
     5. **Post-Merge:**
        - The apply workflow will run to apply the approved changes to the infrastructure.
        - Monitor the workflow for successful execution.

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
- [Mineiros GitHub Organization Module](https://github.com/mineiros-io/terraform-github-organization)
- [Mineiros GitHub Team Module](https://github.com/mineiros-io/terraform-github-team)
- [Mineiros GitHub Repository Module](https://github.com/mineiros-io/terraform-github-repository)
- [gruntwork-io/terragrunt-action (GitHub Action)](https://github.com/gruntwork-io/terragrunt-action)
