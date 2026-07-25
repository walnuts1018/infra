resource "zitadel_project" "stalwart" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "Stalwart"
  project_role_assertion = false
}

resource "zitadel_application_oidc" "stalwart" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.stalwart.id
  name       = "stalwart"

  redirect_uris             = ["https://stalwart.local.walnuts.dev/account/oauth/callback"]
  response_types            = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types               = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type          = "OIDC_AUTH_METHOD_TYPE_NONE"
  post_logout_redirect_uris = ["https://stalwart.local.walnuts.dev/account/"]
  version                   = "OIDC_VERSION_1_0"
  clock_skew                = "0s"
  dev_mode                  = false
  access_token_type         = "OIDC_TOKEN_TYPE_JWT"
}

output "stalwart_oidc_client_id" {
  value       = zitadel_application_oidc.stalwart.client_id
  description = "Client ID for Stalwart's ZITADEL OpenID Connect directory"
}
