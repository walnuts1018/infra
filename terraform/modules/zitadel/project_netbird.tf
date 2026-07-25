resource "zitadel_project" "netbird" {
  org_id = zitadel_org.ZITADEL.id
  name   = "NetBird"
}

resource "zitadel_application_oidc" "netbird" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.netbird.id
  name       = "NetBird Dashboard"

  redirect_uris = [
    "https://netbird.walnuts.dev/auth",
    "https://netbird.walnuts.dev/silent-auth",
    "http://localhost:53000",
  ]
  response_types            = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types               = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE", "OIDC_GRANT_TYPE_REFRESH_TOKEN"]
  auth_method_type          = "OIDC_AUTH_METHOD_TYPE_NONE"
  post_logout_redirect_uris = ["https://netbird.walnuts.dev/"]
  version                   = "OIDC_VERSION_1_0"
  clock_skew                = "0s"
  dev_mode                  = false
  access_token_type         = "OIDC_TOKEN_TYPE_JWT"
}

output "netbird_oidc_client_id" {
  value       = zitadel_application_oidc.netbird.client_id
  description = "Store in 1Password as netbird.oidc-client-id"
}
