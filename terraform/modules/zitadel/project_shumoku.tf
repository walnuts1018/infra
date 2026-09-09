resource "zitadel_project" "shumoku" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "Shumoku"
  project_role_assertion = false
}

resource "zitadel_application_oidc" "shumoku" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.shumoku.id
  name       = "shumoku"

  redirect_uris               = ["https://shumoku.walnuts.dev/oauth2/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = ["https://shumoku.walnuts.dev/"]
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_JWT"
  access_token_role_assertion = false
  id_token_role_assertion     = false
  id_token_userinfo_assertion = false
}

output "shumoku_oidc_client_id" {
  value       = nonsensitive(zitadel_application_oidc.shumoku.client_id)
  description = "Client ID for Shumoku's Envoy Gateway OIDC policy"
}

output "shumoku_oidc_client_secret" {
  value       = zitadel_application_oidc.shumoku.client_secret
  sensitive   = true
  description = "Store this in 1Password item shumoku as client_secret"
}
