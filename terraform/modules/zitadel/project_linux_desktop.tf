resource "zitadel_project" "linux_desktop" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "Linux Desktop"
  project_role_check     = true
  project_role_assertion = true
}

resource "zitadel_project_role" "linux_desktop_user" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.linux_desktop.id
  role_key     = "linux-desktop-user"
  display_name = "Linux Desktop User"
}

resource "zitadel_application_oidc" "linux_desktop" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.linux_desktop.id
  name       = "linux-desktop"

  redirect_uris               = ["https://desktop.walnuts.dev/oauth2/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = ["https://desktop.walnuts.dev/"]
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_JWT"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
}

resource "zitadel_user_grant" "walnuts_linux_desktop_user" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.linux_desktop.id
  user_id    = local.zitadel_human_user_ids.walnuts
  role_keys  = [zitadel_project_role.linux_desktop_user.role_key]
}

output "linux_desktop_oidc_client_id" {
  value = nonsensitive(zitadel_application_oidc.linux_desktop.client_id)
}

output "linux_desktop_oidc_client_secret" {
  value     = zitadel_application_oidc.linux_desktop.client_secret
  sensitive = true
}
