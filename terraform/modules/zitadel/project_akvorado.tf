resource "zitadel_project" "akvorado" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "akvorado"
  project_role_assertion = true
}

resource "zitadel_project_role" "akvorado_admin" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.akvorado.id
  role_key     = "akvorado-admin"
  display_name = "Akvorado Admin"
}

resource "zitadel_application_oidc" "akvorado" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.akvorado.id
  name       = "akvorado"

  redirect_uris               = ["https://akvorado.walnuts.dev/oauth2/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = ["https://akvorado.walnuts.dev/"]
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_JWT"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
}

resource "zitadel_user_grant" "walnuts_akvorado" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.akvorado.id
  user_id    = local.zitadel_human_user_ids.walnuts
  role_keys  = [zitadel_project_role.akvorado_admin.role_key]
}

output "akvorado_oidc_client_id" {
  value = zitadel_application_oidc.akvorado.client_id
}

output "akvorado_project_id" {
  value = zitadel_project.akvorado.id
}
