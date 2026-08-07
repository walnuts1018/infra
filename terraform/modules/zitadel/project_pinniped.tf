resource "zitadel_project" "pinniped" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "Pinniped"
  project_role_assertion = true
}

resource "zitadel_project_role" "pinniped_admin" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.pinniped.id
  role_key     = "pinniped-admin"
  display_name = "Pinniped Administrator"
}

resource "zitadel_user_grant" "walnuts_pinniped_admin" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.pinniped.id
  user_id    = local.zitadel_human_user_ids.walnuts
  role_keys  = [zitadel_project_role.pinniped_admin.role_key]
}

resource "zitadel_application_oidc" "pinniped" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.pinniped.id
  name       = "Pinniped Supervisor"

  redirect_uris               = ["https://kurumi-pinniped.local.walnuts.dev/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE", "OIDC_GRANT_TYPE_REFRESH_TOKEN"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = ["https://kurumi-pinniped.local.walnuts.dev/"]
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_JWT"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
}

output "pinniped_oidc_client_id" {
  value       = nonsensitive(zitadel_application_oidc.pinniped.client_id)
  description = "Client ID for Pinniped Supervisor's ZITADEL upstream OIDC client"
}

output "pinniped_oidc_client_secret" {
  value       = zitadel_application_oidc.pinniped.client_secret
  sensitive   = true
  description = "Client secret for Pinniped Supervisor's ZITADEL upstream OIDC client"
}
