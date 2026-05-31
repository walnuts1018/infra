resource "zitadel_project" "terrakube" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "terrakube"
  project_role_assertion = true
}

resource "zitadel_project_role" "terrakube_admin" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.terrakube.id
  role_key     = "admin"
  display_name = "Admin"
}

resource "zitadel_application_oidc" "terrakube_ui" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.terrakube.id
  name       = "UI"

  redirect_uris               = ["https://terrakube-api.walnuts.dev/dex/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = []
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = false
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
}

resource "zitadel_user_grant" "walnuts_terrakube_admin" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.terrakube.id
  user_id    = local.zitadel_human_user_ids.walnuts
  role_keys  = ["admin"]
}
