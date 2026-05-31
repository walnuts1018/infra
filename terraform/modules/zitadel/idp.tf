resource "zitadel_idp_google" "google" {
  name                = "Google"
  client_id           = "661882345333-i5c93j1qo5ljhkre93qt0pnicmpsv9b7.apps.googleusercontent.com"
  client_secret       = var.google_idp_client_secret
  scopes              = ["openid", "profile", "email"]
  is_auto_creation    = false
  is_auto_update      = false
  is_creation_allowed = true
  is_linking_allowed  = true
}
