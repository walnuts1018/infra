resource "zitadel_idp_google" "google" {
  name                = "Google"
  client_id           = "661882345333-a9amfndet11i4t0il0tnm5v07406pqvt.apps.googleusercontent.com"
  client_secret       = var.google_idp_client_secret
  scopes              = ["openid", "profile", "email"]
  is_auto_creation    = false
  is_auto_update      = false
  is_creation_allowed = true
  is_linking_allowed  = true
}

# resource "zitadel_org_idp_github" "github" {
#   org_id              = zitadel_org.ZITADEL.id
#   name                = "GitHub"
#   client_id           = "ee9727e0d25aa0bb7303"
#   client_secret       = var.github_idp_client_secret
#   scopes              = ["openid", "profile", "email"]
#   is_auto_creation    = false
#   is_auto_update      = false
#   is_creation_allowed = true
#   is_linking_allowed  = true
# }
