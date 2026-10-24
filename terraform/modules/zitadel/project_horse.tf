resource "zitadel_project" "horse" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "Horse"
  project_role_assertion = false
}

resource "zitadel_application_oidc" "horse" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.horse.id
  name       = "Horse"

  redirect_uris               = ["https://horse.walnuts.dev/auth/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = ["https://horse.walnuts.dev/"]
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_JWT"
  access_token_role_assertion = false
  id_token_role_assertion     = false
  id_token_userinfo_assertion = true

  login_version {
    login_v2 {
      base_uri = "https://auth.walnuts.dev/ui/v2/login"
    }
  }
}

output "horse_oidc_client_id" {
  value = nonsensitive(zitadel_application_oidc.horse.client_id)
}

output "horse_oidc_client_secret" {
  value     = zitadel_application_oidc.horse.client_secret
  sensitive = true
}
