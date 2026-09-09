resource "zitadel_project" "openchokin" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "OpenChokin"
  project_role_assertion = false
}

resource "zitadel_application_oidc" "openchokin_frontend" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.openchokin.id
  name       = "Frontend"

  redirect_uris = [
    "https://openchokin.walnuts.dev",
    "https://openchokin.local.walnuts.dev",
  ]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
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

resource "zitadel_application_api" "openchokin_backend" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.openchokin.id
  name       = "Backend"

  auth_method_type = "API_AUTH_METHOD_TYPE_PRIVATE_KEY_JWT"
}
