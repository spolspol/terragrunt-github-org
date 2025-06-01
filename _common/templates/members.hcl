# Members Management Template
# This template provides standardized GitHub organization member management
# Include this template in your Terragrunt configurations for consistent member setups

terraform {
  source = "github.com/mineiros-io/terraform-github-organization?ref=v0.9.0"
}

locals {
  # Default member configuration
  default_members_config = {
    # Member lists - must be provided in specific implementations
    members = [] # List of regular members
    admins  = [] # List of organization administrators

    # All members team configuration
    all_members_team_name       = "all-members"
    all_members_team_visibility = "secret" # Hide membership from public
    catch_non_existing_members  = false    # Don't fail on non-existent users

    # Blocked users
    blocked_users = [] # List of blocked GitHub usernames

    # Outside collaborators
    outside_collaborators = [] # External collaborators with limited access
  }

  # Unified member settings for organization
  unified_members_config = {
    all_members_team_visibility = "secret"
    catch_non_existing_members  = false
    max_outside_collaborators   = 10
  }

  # Default member roles and permissions
  default_member_permissions = {
    # Base permissions for all members
    base_repository_permission = "read"

    # Member capabilities
    can_create_repositories          = true
    can_create_public_repositories   = false
    can_create_private_repositories  = true
    can_fork_private_repositories    = false
    can_change_repository_visibility = false
  }

  # Role-based access patterns
  member_role_mappings = {
    # Maps roles to typical permissions and team memberships
    devops = {
      default_teams          = ["devops"]
      repository_permissions = ["maintain", "admin"]
    }
    data_engineer = {
      default_teams          = ["data-engineering"]
      repository_permissions = ["push", "maintain"]
    }
    data_analyst = {
      default_teams          = ["data-analysts"]
      repository_permissions = ["pull"]
    }
    admin = {
      default_teams          = ["admins"]
      repository_permissions = ["admin"]
    }
  }
}

# Default inputs - these will be merged with specific configurations
inputs = merge(
  local.default_members_config,
  local.unified_members_config,
  {
    # Member management
    members = try(var.members, local.default_members_config.members)
    admins  = try(var.admins, local.default_members_config.admins)

    # All members team configuration
    all_members_team_name = try(
      var.all_members_team_name,
      local.default_members_config.all_members_team_name
    )
    all_members_team_visibility = try(
      var.all_members_team_visibility,
      local.unified_members_config.all_members_team_visibility,
      local.default_members_config.all_members_team_visibility
    )
    catch_non_existing_members = try(
      var.catch_non_existing_members,
      local.unified_members_config.catch_non_existing_members,
      local.default_members_config.catch_non_existing_members
    )

    # Blocked users
    blocked_users = try(var.blocked_users, local.default_members_config.blocked_users)

    # Outside collaborators
    outside_collaborators = try(
      var.outside_collaborators,
      local.default_members_config.outside_collaborators
    )

    # Labels
    labels = {
      managed_by = "terragrunt"
      component  = "members"
    }
  }
)
