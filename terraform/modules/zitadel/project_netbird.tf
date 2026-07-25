resource "zitadel_project" "netbird" {
  org_id = zitadel_org.ZITADEL.id
  name   = "NetBird"
}

resource "zitadel_application_oidc" "netbird" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.netbird.id
  name       = "NetBird SSO"

  redirect_uris             = ["https://netbird.walnuts.dev/oauth2/callback"]
  response_types            = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types               = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE", "OIDC_GRANT_TYPE_REFRESH_TOKEN"]
  auth_method_type          = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris = ["https://netbird.walnuts.dev/oauth2/logout/callback"]
  version                   = "OIDC_VERSION_1_0"
  clock_skew                = "0s"
  dev_mode                  = false
  access_token_type         = "OIDC_TOKEN_TYPE_JWT"
}

output "netbird_oidc_client_id" {
  value       = zitadel_application_oidc.netbird.client_id
  description = "Client ID for NetBird's ZITADEL identity-provider connector"
}

output "netbird_oidc_client_secret" {
  value       = zitadel_application_oidc.netbird.client_secret
  sensitive   = true
  description = "Client secret for NetBird's ZITADEL identity-provider connector"
}
