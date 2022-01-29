# oauth
resource "cloudflare_access_identity_provider" "github_oauth" {
  account_id = "4292ffd8f8bea47f9a717918df90162b"
  name       = "GitHub OAuth"
  type       = "github"
  config {
    client_id     = "bebb319c22b975b8c750"
    client_secret = "b431c08ffba942a1804da2476b496e9c1915c69f"
  }
}