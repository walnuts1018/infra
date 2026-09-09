resource "zitadel_project" "httpdump" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "httpdump"
  project_role_assertion = false
}

resource "zitadel_application_oidc" "httpdump_envoy" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.httpdump.id
  name       = "Envoy"
  redirect_uris = [
    "https://httptest.walnuts.dev/oauth2/callback",
    "https://httptest.local.walnuts.dev/oauth2/callback",
  ]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = ["https://httptest.walnuts.dev/logout"]
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = false
  id_token_role_assertion     = true
  id_token_userinfo_assertion = false
}
