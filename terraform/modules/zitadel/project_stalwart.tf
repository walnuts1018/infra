resource "zitadel_project" "stalwart" {
  org_id             = zitadel_org.ZITADEL.id
  name               = "Stalwart"
  project_role_check = true
}

resource "zitadel_project_role" "stalwart_user" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.stalwart.id
  role_key     = "user"
  display_name = "User"
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

resource "zitadel_user_grant" "walnuts_stalwart_user" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.stalwart.id
  user_id    = local.zitadel_human_user_ids.walnuts
  role_keys  = [zitadel_project_role.stalwart_user.role_key]
}

output "stalwart_oidc_client_id" {
  value       = nonsensitive(zitadel_application_oidc.stalwart.client_id)
  description = "Client ID for Stalwart's ZITADEL OpenID Connect directory"
}
