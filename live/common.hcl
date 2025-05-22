locals {
  owner = get_env("GITHUB_OWNER")  # Organization name/owner
  github_token = get_env("GITHUB_TOKEN")  # GitHub Personal Access Token
}