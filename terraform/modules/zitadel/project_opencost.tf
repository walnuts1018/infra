resource "zitadel_project" "opencost" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "OpenCost"
  project_role_assertion = false
}

resource "zitadel_application_oidc" "opencost" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.opencost.id
  name       = "opencost"

  redirect_uris               = ["https://opencost.walnuts.dev/oauth2/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = ["https://opencost.walnuts.dev/"]
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_JWT"
  access_token_role_assertion = false
  id_token_role_assertion     = false
  id_token_userinfo_assertion = false
}

output "opencost_oidc_client_id" {
  value = nonsensitive(zitadel_application_oidc.opencost.client_id)
}

output "opencost_oidc_client_secret" {
  value     = zitadel_application_oidc.opencost.client_secret
  sensitive = true
}
