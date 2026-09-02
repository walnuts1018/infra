resource "zitadel_project" "picca" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "Picca"
  project_role_assertion = true
}

resource "zitadel_project_role" "picca_admin" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.picca.id
  role_key     = "picca-admin"
  display_name = "Picca Admin"
}

resource "zitadel_application_oidc" "picca" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.picca.id
  name       = "picca"

  redirect_uris               = ["https://picca.walnuts.dev/auth/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = ["https://picca.walnuts.dev/"]
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_JWT"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
}

resource "zitadel_user_grant" "walnuts_picca" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.picca.id
  user_id    = local.zitadel_human_user_ids.walnuts
  role_keys  = [zitadel_project_role.picca_admin.role_key]
}

output "picca_oidc_client_id" {
  value = nonsensitive(zitadel_application_oidc.picca.client_id)
}

output "picca_oidc_client_secret" {
  value     = zitadel_application_oidc.picca.client_secret
  sensitive = true
}

resource "zitadel_application_oidc" "picca_dev" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.picca.id
  name       = "picca-dev"

  redirect_uris               = ["https://picca-dev.walnuts.dev/auth/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = ["https://picca-dev.walnuts.dev/"]
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_JWT"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
}

resource "zitadel_user_grant" "walnuts_picca_dev" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.picca.id
  user_id    = local.zitadel_human_user_ids.walnuts
  role_keys  = [zitadel_project_role.picca_admin.role_key]
}

output "picca_dev_oidc_client_id" {
  value = nonsensitive(zitadel_application_oidc.picca_dev.client_id)
}

output "picca_dev_oidc_client_secret" {
  value     = zitadel_application_oidc.picca_dev.client_secret
  sensitive = true
}
