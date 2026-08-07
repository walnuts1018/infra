resource "zitadel_project" "headlamp" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "Headlamp"
  project_role_assertion = true
}

resource "zitadel_project_role" "headlamp_user" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.headlamp.id
  role_key     = "headlamp-user"
  display_name = "Headlamp User"
}

resource "zitadel_user_grant" "walnuts_headlamp" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.headlamp.id
  user_id    = local.zitadel_human_user_ids.walnuts
  role_keys  = [zitadel_project_role.headlamp_user.role_key]
}

resource "zitadel_application_oidc" "headlamp" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.headlamp.id
  name       = "headlamp"

  redirect_uris               = ["https://headlamp.walnuts.dev/oidc-callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = ["https://headlamp.walnuts.dev/"]
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_JWT"
  access_token_role_assertion = false
  id_token_role_assertion     = false
  id_token_userinfo_assertion = false
}

output "headlamp_oidc_client_id" {
  value       = nonsensitive(zitadel_application_oidc.headlamp.client_id)
  description = "Client ID for Headlamp's OIDC login"
}

output "headlamp_oidc_client_secret" {
  value       = zitadel_application_oidc.headlamp.client_secret
  sensitive   = true
  description = "Store this in 1Password item headlamp as client_secret"
}
