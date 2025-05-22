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