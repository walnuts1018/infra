resource "zitadel_project" "hubble" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "Hubble"
  project_role_assertion = true
}

resource "zitadel_project_role" "hubble_user" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.hubble.id
  role_key     = "hubble-user"
  display_name = "Hubble User"
}

resource "zitadel_application_oidc" "hubble" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.hubble.id
  name       = "hubble"

  redirect_uris               = ["https://hubble.walnuts.dev/oauth2/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = ["https://hubble.walnuts.dev/oauth2/logout"]
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_JWT"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
}

resource "zitadel_user_grant" "walnuts_hubble" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.hubble.id
  user_id    = local.zitadel_human_user_ids.walnuts
  role_keys  = ["hubble-user"]
}
