# Environment Variables Management

This document explains how environment variables are centrally managed in the GitHub Actions workflows.

## Overview

All environment variables used across GitHub Actions workflows are now defined in a single source: `.github/workflows/common-env.yml`. This approach provides:

- **Single source of truth** for tool versions and configuration
- **Consistency** across all workflows
- **Easy maintenance** when updating versions
- **Reduced duplication** and human error

## Central Environment Variables

The following environment variables are defined in `common-env.yml`:

### Tool Versions
- `TERRAGRUNT_VERSION: '0.80.4'` - Terragrunt version
- `TOFU_VERSION: '1.10.0-beta2'` - OpenTofu version

### Terragrunt Configuration
- `TERRAGRUNT_EXPERIMENTAL: 'true'` - Enable experimental features
- `TG_NON_INTERACTIVE: 'true'` - Non-interactive mode
- `TERRAGRUNT_USE_EXPERIMENTAL_CLI: 'true'` - Use experimental CLI redesign

### Experimental Features  
- `TG_EXPERIMENT_MODE: 'true'` - Terragrunt experimental mode
- `TG_BACKEND_BOOTSTRAP: 'true'` - Backend bootstrap mode

### Cloud Configuration (Example: GCP)
- `GCP_PROJECT_ID: 'your-project-id'` - Cloud project identifier
- `GCP_REGION: 'your-region'` - Cloud region

## Usage Pattern

Each workflow that needs these environment variables follows this pattern:

1. **Call common-env workflow**: First job calls the reusable workflow
2. **Pass variables as outputs**: Environment variables are exposed as job outputs
3. **Use in dependent jobs**: Other jobs reference these outputs via `needs`

### Example Workflow Structure

```yaml
jobs:
  get-env:
    name: 📋 Get Common Environment
    uses: ./.github/workflows/common-env.yml
    
  main-job:
    name: Main Job
    runs-on: ubuntu-latest
    needs: get-env
    env:
      TERRAGRUNT_VERSION: ${{ needs.get-env.outputs.terragrunt_version }}
      TOFU_VERSION: ${{ needs.get-env.outputs.tofu_version }}
      TERRAGRUNT_EXPERIMENTAL: ${{ needs.get-env.outputs.terragrunt_experimental }}
      TG_EXPERIMENT_MODE: ${{ needs.get-env.outputs.tg_experiment_mode }}
      TG_BACKEND_BOOTSTRAP: ${{ needs.get-env.outputs.tg_backend_bootstrap }}
      GCP_PROJECT_ID: ${{ needs.get-env.outputs.gcp_project_id }}
      GCP_REGION: ${{ needs.get-env.outputs.gcp_region }}
```

## Workflows Using Centralized Environment Variables

The following workflows have been migrated to use the centralized environment variables:

- `.github/workflows/terragrunt-unified-reusable.yml`
- `.github/workflows/terragrunt-pr-orchestrator.yml`
- `.github/workflows/terragrunt-apply-orchestrator.yml`
- `.github/workflows/workflow-test.yml`

## Updating Environment Variables

To update any environment variable (e.g., tool versions):

1. Edit `.github/workflows/common-env.yml`
2. Update the values in the `env:` section
3. Commit the changes
4. All workflows will automatically use the new values

### Example: Updating Terragrunt Version

```yaml
# In .github/workflows/common-env.yml
env:
  TERRAGRUNT_VERSION: '0.81.0'  # Changed from 0.80.4
  # ... other variables remain unchanged
```

## Benefits

- **Consistency**: All workflows use identical tool versions
- **Maintainability**: Single place to update versions
- **Visibility**: Clear view of all environment configuration
- **Reduced Errors**: No risk of version mismatches between workflows
- **Efficiency**: Reusable workflow reduces duplication

## Migration Notes

During the migration from distributed to centralized environment variables:

- Removed individual `env:` sections from workflow files
- Added `get-env` job as first job in each workflow
- Updated job dependencies with `needs: get-env`
- Environment variables are now passed as job outputs

This ensures all workflows maintain the same behavior while using centralized configuration management.
