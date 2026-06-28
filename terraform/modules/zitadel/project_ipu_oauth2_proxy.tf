resource "zitadel_project" "ipu_oauth2_proxy" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "IPU OAuth2-Proxy"
  project_role_assertion = true
}

resource "zitadel_project_role" "ipu_viewer" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.ipu_oauth2_proxy.id
  role_key     = "viewer"
  display_name = "Viewer"
}

resource "zitadel_application_oidc" "ipu_oauth2_proxy_app" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.ipu_oauth2_proxy.id
  name       = "oauth2-proxy"

  redirect_uris               = ["https://ipu.walnuts.dev/auth/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = []
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = false
  id_token_role_assertion     = false
  id_token_userinfo_assertion = false
}

resource "zitadel_user_grant" "walnuts_ipu_viewer" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.ipu_oauth2_proxy.id
  user_id    = local.zitadel_human_user_ids.walnuts
  role_keys  = [zitadel_project_role.ipu_viewer.role_key]
}
