resource "zitadel_project" "dependency_track" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "Dependency-Track"
  project_role_assertion = false
  project_role_check     = true
}

resource "zitadel_project_role" "dependency_track_user" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.dependency_track.id
  role_key     = "dependency-track-user"
  display_name = "Dependency-Track User"
}

resource "zitadel_user_grant" "walnuts_dependency_track" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.dependency_track.id
  user_id    = local.zitadel_human_user_ids.walnuts
  role_keys  = [zitadel_project_role.dependency_track_user.role_key]
}

resource "zitadel_application_oidc" "dependency_track" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.dependency_track.id
  name       = "dependency-track"

  redirect_uris               = ["https://dependency-track.walnuts.dev/oauth2/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = ["https://dependency-track.walnuts.dev/"]
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_JWT"
  access_token_role_assertion = false
  id_token_role_assertion     = false
  id_token_userinfo_assertion = false
}

output "dependency_track_oidc_client_id" {
  value = nonsensitive(zitadel_application_oidc.dependency_track.client_id)
}

output "dependency_track_oidc_client_secret" {
  value     = zitadel_application_oidc.dependency_track.client_secret
  sensitive = true
}
