# GitHub Organization Workflows Documentation

This document provides comprehensive information about the GitHub Actions workflows that manage CI/CD for the GitHub organization infrastructure using Terragrunt and OpenTofu.

## Overview

The repository uses a **unified orchestrated workflow system** that provides efficient, dependency-aware management of GitHub organization resources. The system is designed to:

- **Validate organization changes** on pull requests with two-step validation
- **Deploy organization changes** on pushes to main branch
- **Support manual execution** with flexible resource targeting
- **Respect dependency order** for resource deployment
- **Provide parallel execution** within dependency constraints
- **Fail fast** to prevent cascading issues
- **Provide detailed reporting** for each operation

## Current Workflow Architecture

### Orchestrator-Based System

The workflow system uses orchestrator workflows that coordinate resource management:

1. **PR Orchestrator** - Validates changes across multiple resource types
2. **Apply Orchestrator** - Deploys changes in proper dependency order
3. **Unified Reusable Workflow** - Shared workflow template for all operations

### Workflow Types

| Type | Purpose | Trigger | File |
|------|---------|---------|------|
| **PR Validation** | Validate changes before merge | `pull_request` | `terragrunt-pr-orchestrator.yml` |
| **Apply/Deploy** | Deploy organization changes | `push` + `workflow_dispatch` | `terragrunt-apply-orchestrator.yml` |
| **Reusable Template** | Shared workflow logic | Called by orchestrators | `terragrunt-unified-reusable.yml` |

## Resource Types

The system manages four main resource types in dependency order:

```
Step 1: 🏢 Organization Settings
    ↓
Step 2: 👥 Members  
    ↓
Step 3: 🏗️ Teams
    ↓
Step 4: 📦 Repositories
```

### Resource Dependencies

- **Organization Settings** - Must be applied first (foundation)
- **Members** - Depends on organization settings
- **Teams** - Depends on members being present
- **Repositories** - Depends on teams for access control

## Unified Reusable Workflow

The system uses a single reusable workflow template that handles all resource types with configurable behavior.

### Reusable Workflow Features

| Feature | Description |
|---------|-------------|
| **Matrix Strategy** | Processes multiple resources in parallel |
| **Two-Step Validation** | Format Check (blocking) → Plan Validation |
| **Dynamic Resource Naming** | Extracts resource names from paths automatically |
| **Environment Integration** | Uses centralized environment variables |
| **Comprehensive Reporting** | Detailed PR comments and step summaries |

### Workflow Parameters

The reusable workflow accepts these inputs:

```yaml
inputs:
  mode: 'validate' | 'apply'           # Operation mode
  resource_type: string                # Resource type identifier  
  resource_paths: string               # JSON array of paths to process
  resource_emoji: string               # Display emoji for resource type
  requires_approval: boolean           # Whether manual approval required
```

### Path Patterns

Workflows trigger on changes to these paths:

```yaml
paths:
  - 'live/**'                         # All live configurations
  - '_common/**'                      # Common templates and settings
  - 'root.hcl'                        # Root configuration changes
```

## Orchestrator Workflows

Orchestrator workflows handle multiple resource types with proper dependency management.

### Orchestrator Types

| Workflow | Purpose | File |
|----------|---------|------|
| **PR Orchestrator** | Validate multi-resource changes | `terragrunt-pr-orchestrator.yml` |
| **Apply Orchestrator** | Deploy multi-resource changes | `terragrunt-apply-orchestrator.yml` |

### Execution Order

The orchestrator follows this dependency-aware execution order:

```
Step 1: 🏢 Organization Settings
    ↓
Step 2: 👥 Members  
    ↓
Step 3: 🏗️ Teams
    ↓
Step 4: 📦 Repositories
```

### Sequential Execution

- Each step waits for the previous step to complete successfully
- **Execution stops** at the first failure to prevent cascading issues
- **Environment protection** is applied for production deployments

### Manual Execution

The Apply Orchestrator supports manual execution with flexible resource targeting:

**Execution Options:**
- `auto-detect` (default) - Automatically detects changed resources
- `org-settings` - Apply only organization settings
- `members` - Apply only member management  
- `teams` - Apply only team management
- `repositories` - Apply only repository management
- `all` - Apply all resources regardless of changes

**Usage:**
1. Navigate to GitHub Actions → Apply Orchestrator
2. Click "Run workflow"
3. Select target resources from dropdown
4. Execute on main branch

## Reusable Workflows

The system uses a single unified reusable workflow to maintain DRY principles and consistent behavior.

### Unified Reusable Workflow

| Workflow | Purpose | Used By |
|----------|---------|---------|
| `terragrunt-unified-reusable.yml` | Handles both validation and apply operations | PR and Apply orchestrators |
| `common-env.yml` | Centralized environment variable management | All workflows |

### Workflow Parameters

```yaml
# Current parameters for unified workflow
inputs:
  mode: "validate"                     # or "apply"
  resource_type: "repositories"        # Resource type identifier
  resource_paths: '["live/repositories/web-app"]'
  resource_emoji: "📦"                 # Display emoji
  requires_approval: true              # Manual approval required
secrets:
  ORG_GITHUB_TOKEN: ${{ secrets.ORG_GITHUB_TOKEN }}
  TF_GOOGLE_CREDENTIALS: ${{ secrets.TF_GOOGLE_CREDENTIALS }}
```

### Key Features

- **Mode-agnostic**: Single workflow handles both validation and apply
- **Resource name extraction**: Automatically derives names from paths
- **Two-step validation**: Format check → Plan validation
- **Comprehensive reporting**: PR comments and step summaries

## Workflow Features

### Change Detection

The system automatically detects which resources have changed:

- **Intelligent git diff analysis** comparing against main branch
- **Template change handling** - common template changes affect all related resources
- **Fallback strategies** for edge cases (first commits, force pushes)
- **Resource type classification** based on file paths
- **Matrix generation** for parallel processing

### Two-Step Validation

The validation process uses a blocking two-step approach:

1. **Format Check (Blocking)**: HCL formatting validation that stops execution if failed
2. **Plan Validation**: Infrastructure planning that only runs if format check passes

This approach saves compute resources by catching formatting issues early.

### Resource Naming

- **Dynamic extraction** of resource names from directory paths
- **Automatic basename calculation** using `basename(get_terragrunt_dir())`
- **Enhanced job naming** showing specific resource being processed
- **Consistent naming patterns** across all workflow runs

### Comprehensive Reporting

Each workflow provides detailed reporting:

- **GitHub Step Summaries** with overall status and details
- **PR/Commit Comments** with specific results for each resource
- **Plan Output** showing proposed organization changes
- **Dependency Analysis** with visual dependency trees

### Security Features

- **Environment protection rules** for production deployments
- **Secret management** through GitHub secrets
- **GitHub token authentication** with organization permissions
- **Audit trails** for all organization changes

## Usage Patterns

### Single Resource Changes

When you modify only one resource type:

1. **Create a PR** with your changes
2. **Individual workflow triggers** automatically
3. **Review the validation results** in PR comments
4. **Merge the PR** if validation passes
5. **Individual apply workflow** deploys changes automatically

### Multi-Resource Changes

When you modify multiple resource types:

1. **Create a PR** with your changes
2. **Orchestrator workflow triggers** automatically
3. **Review orchestrated validation results** showing dependency order
4. **Merge the PR** if all validations pass
5. **Orchestrator apply workflow** deploys in dependency order

### Template Changes

When you modify common templates:

1. **All resources using that template** are automatically included
2. **Orchestrator always handles** template changes
3. **Comprehensive validation** across all affected resources
4. **Coordinated deployment** respecting dependencies

## Workflow Configuration

### Required Secrets

Configure these secrets in your GitHub repository:

| Secret | Description |
|--------|-------------|
| `ORG_GITHUB_TOKEN` | GitHub organization admin token for managing organization resources |

### Environment Variables

All workflows use centralized environment variables from `.github/workflows/common-env.yml`:

```yaml
env:
  TERRAGRUNT_VERSION: "0.80.4"
  TOFU_VERSION: "1.10.0-beta2"
  TG_EXPERIMENT_MODE: "true"
  TG_BACKEND_BOOTSTRAP: "true"
  GCP_PROJECT_ID: "your-project-id"
  GCP_REGION: "your-region"
```

This centralized approach ensures:
- **Consistency** across all workflows
- **Easy maintenance** when updating versions
- **Single source of truth** for configuration

### Environment Protection

Production deployments use GitHub environment protection:

- Manual approval required for production changes
- Environment-specific secrets and variables
- Deployment history and audit trails

## Monitoring and Troubleshooting

### Monitoring Workflows

- **Actions tab** in GitHub repository shows all workflow runs
- **Individual workflow runs** provide detailed logs
- **Step summaries** give high-level status overview
- **Artifacts** are available for download (plan outputs, logs)

### Common Issues

#### 1. Workflow Not Triggering

**Symptoms**: No workflow runs when changes are pushed/PR created

**Solutions**:
- Check path patterns match your file changes
- Verify branch protection rules aren't blocking workflows
- Ensure workflows are enabled in repository settings

#### 2. Orchestrator Not Triggering

**Symptoms**: Individual workflows run when multiple resources changed

**Solutions**:
- Check the change detection logic in individual workflows
- Verify resource patterns in orchestrator detection
- Review git diff output in workflow logs

#### 3. Authentication Failures

**Symptoms**: "Permission denied" or "Could not load credentials" errors

**Solutions**:
- Verify `ORG_GITHUB_TOKEN` secret is properly configured
- Check token has required organization admin permissions
- Ensure token is valid and not expired

#### 4. Dependency Issues

**Symptoms**: Apply workflows fail due to missing dependencies

**Solutions**:
- Review dependency order in orchestrator workflows
- Check that prerequisite resources are deployed
- Verify all required dependencies exist

### Debugging Workflows

#### Enable Debug Logging

Add these environment variables to workflow runs:

```yaml
env:
  TOFU_LOG: DEBUG
  ACTIONS_STEP_DEBUG: true
  ACTIONS_RUNNER_DEBUG: true
```

#### Check Workflow Logs

1. **Navigate to Actions tab** in GitHub
2. **Select the workflow run** you want to debug
3. **Expand workflow steps** to see detailed logs
4. **Download artifacts** for plan outputs and logs

#### Validate Locally

Test workflows locally using `act`:

```bash
# Install act
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Run workflow locally
act pull_request --workflows .github/workflows/individual-repositories-pr.yml
```

## Best Practices

### Workflow Development

1. **Test in feature branches** before merging workflow changes
2. **Use reusable workflows** to maintain consistency
3. **Add comprehensive error handling** and logging
4. **Document workflow changes** in PR descriptions

### Organization Changes

1. **Make small, focused changes** when possible
2. **Review plan outputs** carefully before merging
3. **Test in non-production** patterns first
4. **Monitor deployments** for issues

### Security

1. **Use minimal token permissions** required
2. **Regularly rotate** GitHub tokens
3. **Review workflow logs** for sensitive information exposure
4. **Use environment protection rules** for production

### Performance

1. **Use workflow caching** for Terragrunt binaries and modules
2. **Optimize path patterns** to avoid unnecessary runs
3. **Leverage reusable workflows** for efficiency
4. **Clean up old workflow runs** and artifacts regularly

## Advanced Configuration

### Adding New Resource Types

To add a new resource type (e.g., `integrations`):

1. **Create individual workflows**:
   ```yaml
   # .github/workflows/individual-integrations-pr.yml
   # .github/workflows/individual-integrations-apply.yml
   ```

2. **Update orchestrator workflows**:
   - Add resource detection patterns
   - Add execution step in dependency order
   - Update summary generation

3. **Create reusable template** if needed:
   ```hcl
   # _common/templates/integrations.hcl
   ```

### Custom Orchestration Order

To modify the orchestration order:

1. **Update dependency conditions** in orchestrator workflows
2. **Adjust step dependencies** for new order
3. **Update summary generation** to reflect new order
4. **Test thoroughly** with multi-resource changes

### Environment-Specific Behavior

To add environment-specific workflow behavior:

1. **Add environment detection** logic to workflows
2. **Use conditional steps** based on environment
3. **Configure environment protection rules** in GitHub
4. **Add environment-specific secrets** if needed

## References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Reusable Workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [Environment Protection Rules](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Terragrunt CLI Documentation](https://terragrunt.gruntwork.io/docs/reference/cli-options/)
