resource "zitadel_project" "penpot" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "Penpot"
  project_role_assertion = true
}

resource "zitadel_project_role" "penpot_user" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.penpot.id
  role_key     = "penpot-user"
  display_name = "Penpot User"
}

resource "zitadel_application_oidc" "penpot" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.penpot.id
  name       = "penpot"

  redirect_uris               = ["https://penpot.walnuts.dev/api/auth/oidc/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = ["https://penpot.walnuts.dev/"]
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_JWT"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
}

resource "zitadel_user_grant" "walnuts_penpot" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.penpot.id
  user_id    = local.zitadel_human_user_ids.walnuts
  role_keys  = [zitadel_project_role.penpot_user.role_key]
}

resource "zitadel_user_grant" "k1h_penpot" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.penpot.id
  user_id    = local.zitadel_human_user_ids.k1h
  role_keys  = [zitadel_project_role.penpot_user.role_key]
}

output "penpot_oidc_client_id" {
  value = nonsensitive(zitadel_application_oidc.penpot.client_id)
}

output "penpot_oidc_client_secret" {
  value     = zitadel_application_oidc.penpot.client_secret
  sensitive = true
}

output "penpot_project_id" {
  value = zitadel_project.penpot.id
}
