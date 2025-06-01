# Configuration Guide

This guide walks you through customizing the GitHub Organization Management template for your specific organization.

## Quick Start Checklist

Follow these steps to configure the template for your organization:

### 1. Organization Configuration (`live/org.hcl`)

Update the organization identity settings:

```hcl
locals {
  # Basic organization configuration
  owner        = "your-github-org-name"        # Your GitHub organization name
  github_token = get_env("ORG_GITHUB_TOKEN")

  # Organization identity - UPDATE THESE VALUES
  org_name        = "Your Organization Name"    # Display name
  org_description = "Your Organization Description"
  company_name    = "Your Company Name"
  website_url     = "https://your-organization.com"
  org_location    = "Your Location"
  billing_email   = "admin@your-organization.com"

  # Organization labels
  org_labels = {
    organization = "your-github-org-name"      # Should match 'owner' above
    managed_by   = "terragrunt"
    component    = "github-org"
  }
}
```

### 2. Common Configuration (`_common/common.hcl`)

Update the common settings:

```hcl
locals {
  # Common naming conventions - UPDATE THESE
  name_prefix = "your-prefix"                  # Short prefix (2-4 chars)
  org_name    = "your-github-org-name"         # Should match org.hcl

  # Common labels
  common_labels = {
    terraform_managed = "true"
    repository        = "tg-github-org"
    owner             = "infrastructure-team"
    organization      = "your-github-org-name" # Should match org.hcl
  }

  # Default repository topics
  repository_defaults = {
    topics = ["your-github-org-name", "managed-by-terragrunt"]
  }
}
```

### 3. Backend Configuration (`root.hcl`)

Choose and configure your state backend:

#### Option A: Google Cloud Storage (GCS)
```hcl
remote_state {
  backend = "gcs"
  config = {
    bucket   = "your-terraform-state-bucket"
    prefix   = "github-org/${path_relative_to_include()}"
    project  = "your-gcp-project-id"
    location = "your-region"
  }
}
```

#### Option B: AWS S3
```hcl
remote_state {
  backend = "s3"
  config = {
    bucket         = "your-terraform-state-bucket"
    key            = "github-org/${path_relative_to_include()}/terraform.tfstate"
    region         = "your-aws-region"
    encrypt        = true
    dynamodb_table = "your-terraform-locks-table"
  }
}
```

#### Option C: Azure Storage
```hcl
remote_state {
  backend = "azurerm"
  config = {
    resource_group_name  = "your-resource-group"
    storage_account_name = "your-storage-account"
    container_name       = "terraform-state"
    key                  = "github-org/${path_relative_to_include()}/terraform.tfstate"
  }
}
```

### 4. Members Configuration (`live/members/terragrunt.hcl`)

Add your organization members:

```hcl
inputs = merge(
  local.common_vars.locals.common_labels,
  {
    # Member management - ADD YOUR MEMBERS
    members = [
      "github-username1",
      "github-username2",
      "github-username3",
    ]

    # Organization Admins - ADD YOUR ADMINS
    admins = [
      "admin-username1",
      "admin-username2"
    ]
  }
)
```

### 5. Team Configurations

Update each team in `live/teams/*/terragrunt.hcl`:

#### Admins Team (`live/teams/admins/terragrunt.hcl`)
```hcl
inputs = merge(
  local.common_vars.locals.common_labels,
  {
    members = [
      "admin-username1",
      "admin-username2"
    ]
    maintainers = [
      "admin-username1"
    ]
  }
)
```

#### DevOps Team (`live/teams/devops/terragrunt.hcl`)
```hcl
inputs = merge(
  local.common_vars.locals.common_labels,
  {
    members = [
      "devops-username1",
      "devops-username2"
    ]
    maintainers = [
      "devops-lead-username"
    ]
  }
)
```

### 6. Repository Module Source

If using a custom repository module, update the source in `_common/templates/repository.hcl`:

```hcl
terraform {
  source = "git::https://github.com/your-org/terraform-github-repository.git?ref=v0.20.0-pre1"
}
```

Or use the standard module:
```hcl
terraform {
  source = "github.com/mineiros-io/terraform-github-repository?ref=v0.18.0"
}
```

## Environment Variables

Set these environment variables before running Terragrunt:

```bash
# Required: GitHub token with organization admin permissions
export ORG_GITHUB_TOKEN="your_github_token_here"

# Optional: Backend-specific credentials
export GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account.json"  # For GCS
export AWS_ACCESS_KEY_ID="your_aws_access_key"                        # For S3
export AWS_SECRET_ACCESS_KEY="your_aws_secret_key"                    # For S3
export ARM_CLIENT_ID="your_azure_client_id"                          # For Azure
export ARM_CLIENT_SECRET="your_azure_client_secret"                  # For Azure
export ARM_TENANT_ID="your_azure_tenant_id"                          # For Azure
export ARM_SUBSCRIPTION_ID="your_azure_subscription_id"              # For Azure
```

## Workflow Configuration

### GitHub Actions Environment Variables

Update the workflow environment variables in `.github/workflows/common-env.yml`:

```yaml
env:
  # Tool Versions - Single source of truth
  TERRAGRUNT_VERSION: '0.80.4'
  TOFU_VERSION: '1.10.0-beta2'

  # Terragrunt Configuration
  TG_EXPERIMENT_MODE: 'true'

  # Cloud Configuration - UPDATE THESE VALUES FOR YOUR ORGANIZATION
  # GCP Configuration (if using GCS backend)
  GCP_PROJECT_ID: 'your-gcp-project-id'
  GCP_REGION: 'your-gcp-region'
```

### GitHub Secrets Configuration

Configure these secrets in your GitHub repository settings:

#### Required Secrets
- `ORG_GITHUB_TOKEN`: GitHub token with organization admin permissions

#### Backend-Specific Secrets (choose based on your backend)

**For GCS Backend:**
- `TF_GOOGLE_CREDENTIALS`: Service account JSON key content

**For S3 Backend:**
- `AWS_ACCESS_KEY_ID`: AWS access key
- `AWS_SECRET_ACCESS_KEY`: AWS secret key

**For Azure Backend:**
- `ARM_CLIENT_ID`: Azure client ID
- `ARM_CLIENT_SECRET`: Azure client secret
- `ARM_TENANT_ID`: Azure tenant ID
- `ARM_SUBSCRIPTION_ID`: Azure subscription ID

### Environment Protection

Configure environment protection rules in your repository:

1. Go to **Settings** → **Environments**
2. Create an environment named `approval-required`
3. Configure protection rules:
   - **Required reviewers**: Add team members who should approve deployments
   - **Wait timer**: Optional delay before deployment
   - **Deployment branches**: Restrict to `main` branch

### Workflow Customization

#### Tool Versions
Update tool versions in `.github/workflows/common-env.yml`:
- `TERRAGRUNT_VERSION`: Latest Terragrunt version
- `TOFU_VERSION`: Latest OpenTofu version

#### Cloud Provider Configuration
If using a different cloud provider or region:
1. Update `GCP_PROJECT_ID` and `GCP_REGION` in `common-env.yml`
2. Modify the authentication step in `terragrunt-unified-reusable.yml` if needed
3. Update backend configuration in `root.hcl` to match

## GitHub Token Permissions

Your GitHub token needs these permissions:

### Organization Permissions
- **Administration**: Read and write
- **Members**: Read and write
- **Metadata**: Read

### Repository Permissions
- **Administration**: Read and write
- **Contents**: Read and write
- **Issues**: Read and write
- **Metadata**: Read
- **Pull requests**: Read and write

### Account Permissions
- **Email addresses**: Read (if managing member emails)

## Workflow Badge URLs

Update the workflow status badges in `README.md`:

```markdown
[![Terragrunt PR Workflow](https://github.com/your-org/tg-github-org/actions/workflows/terragrunt-pr-orchestrator.yml/badge.svg)](https://github.com/your-org/tg-github-org/actions/workflows/terragrunt-pr-orchestrator.yml)
[![Terragrunt Apply Workflow](https://github.com/your-org/tg-github-org/actions/workflows/terragrunt-apply-orchestrator.yml/badge.svg)](https://github.com/your-org/tg-github-org/actions/workflows/terragrunt-apply-orchestrator.yml)
```

## Validation Steps

After configuration, validate your setup:

1. **Check configuration syntax:**
   ```bash
   find . -name "*.hcl" -exec terragrunt hclfmt --check {} \;
   ```

2. **Validate organization settings:**
   ```bash
   cd live/org
   terragrunt validate
   terragrunt plan
   ```

3. **Test member management:**
   ```bash
   cd live/members
   terragrunt validate
   terragrunt plan
   ```

4. **Verify team configurations:**
   ```bash
   cd live/teams/admins
   terragrunt validate
   terragrunt plan
   ```

## Common Configuration Patterns

### Multi-Environment Setup

If you want to manage multiple environments (dev, staging, prod):

```
live/
├── dev/
│   ├── org/
│   ├── members/
│   └── teams/
├── staging/
│   ├── org/
│   ├── members/
│   └── teams/
└── prod/
    ├── org/
    ├── members/
    └── teams/
```

### Repository Categories

Organize repositories by type:

```
live/repositories/
├── infrastructure/
│   ├── tg-github-org/
│   └── terraform-modules/
├── applications/
│   ├── web-app/
│   └── api-service/
└── data/
    ├── data-pipeline/
    └── analytics-dashboard/
```

### Team Hierarchies

Create team hierarchies for larger organizations:

```
live/teams/
├── engineering/
│   ├── frontend/
│   ├── backend/
│   └── mobile/
├── data/
│   ├── engineering/
│   └── analytics/
└── operations/
    ├── devops/
    ├── security/
    └── platform/
```

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Verify `ORG_GITHUB_TOKEN` is set and valid
   - Check token permissions include organization admin access
   - Ensure token hasn't expired

2. **Backend Configuration Errors**
   - Verify backend credentials are properly configured
   - Check bucket/container exists and is accessible
   - Ensure proper permissions for state storage

3. **Module Source Errors**
   - Verify module sources are accessible
   - Check version tags exist
   - Ensure proper authentication for private modules

4. **Resource Import Issues**
   - Use the import script: `./scripts/import-repository.sh <repo-name>`
   - Verify resource addresses match Terraform configuration
   - Check repository exists and is accessible

### Getting Help

- Check the [GitHub Actions logs](../../actions) for workflow errors
- Review [Terragrunt documentation](https://terragrunt.gruntwork.io/docs/)
- Consult [Mineiros module documentation](https://github.com/mineiros-io)
- Open an issue in this repository for template-specific problems

## Next Steps

After configuration:

1. **Initialize the organization:**
   ```bash
   cd live/org && terragrunt apply
   ```

2. **Set up members:**
   ```bash
   cd live/members && terragrunt apply
   ```

3. **Create teams:**
   ```bash
   cd live/teams/admins && terragrunt apply
   ```

4. **Configure repositories:**
   ```bash
   cd live/repositories/tg-github-org && terragrunt apply
   ```

5. **Set up GitHub Actions:**
   - Ensure workflows are enabled
   - Configure environment protection rules
   - Test PR and apply workflows 