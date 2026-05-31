resource "zitadel_project" "ipxe_manager" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "iPXE Manager"
  project_role_assertion = false
}

resource "zitadel_application_oidc" "ipxe_manager_front" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.ipxe_manager.id
  name       = "Front"

  redirect_uris  = ["https://pxe-manager.walnuts.dev/auth/callback"]
  response_types = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types = [
    "OIDC_GRANT_TYPE_AUTHORIZATION_CODE",
    "OIDC_GRANT_TYPE_REFRESH_TOKEN",
  ]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_NONE"
  post_logout_redirect_uris   = []
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = false
  id_token_role_assertion     = false
  id_token_userinfo_assertion = false
}

resource "zitadel_application_api" "ipxe_manager_api_server" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.ipxe_manager.id
  name       = "API Server"

  auth_method_type = "API_AUTH_METHOD_TYPE_BASIC"
}
