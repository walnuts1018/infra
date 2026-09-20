resource "zitadel_project" "beast" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "Beast"
  project_role_check     = true
  project_role_assertion = true
}

resource "zitadel_project_role" "beast_user" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.beast.id
  role_key     = "beast-user"
  display_name = "Beast User"
}

resource "zitadel_application_oidc" "beast" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.beast.id
  name       = "beast"

  redirect_uris               = ["https://beast.walnuts.dev/api/auth/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = ["https://beast.walnuts.dev/"]
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_JWT"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
}

resource "zitadel_user_grant" "walnuts_beast_user" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.beast.id
  user_id    = local.zitadel_human_user_ids.walnuts
  role_keys  = [zitadel_project_role.beast_user.role_key]
}

output "beast_oidc_client_id" {
  value = nonsensitive(zitadel_application_oidc.beast.client_id)
}

output "beast_oidc_client_secret" {
  value     = zitadel_application_oidc.beast.client_secret
  sensitive = true
}
