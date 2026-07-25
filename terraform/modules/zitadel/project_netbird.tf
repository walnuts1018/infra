resource "zitadel_project" "netbird" {
  org_id             = zitadel_org.ZITADEL.id
  name               = "NetBird"
  project_role_check = true
}

resource "zitadel_project_role" "netbird_user" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.netbird.id
  role_key     = "user"
  display_name = "User"
}

// ZITADEL returns an OIDC client secret only when the application is created.
// Recreate the application once to restore the missing secret in Terraform state.
resource "terraform_data" "netbird_oidc_application_recreate" {
  input = "restore-netbird-oidc-client-secret"
}

resource "zitadel_application_oidc" "netbird" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.netbird.id
  name       = "NetBird SSO"

  redirect_uris             = ["https://netbird.walnuts.dev/oauth2/callback"]
  response_types            = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types               = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE", "OIDC_GRANT_TYPE_REFRESH_TOKEN"]
  auth_method_type          = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris = ["https://netbird.walnuts.dev/oauth2/logout/callback"]
  version                   = "OIDC_VERSION_1_0"
  clock_skew                = "0s"
  dev_mode                  = false
  access_token_type         = "OIDC_TOKEN_TYPE_JWT"

  lifecycle {
    replace_triggered_by = [terraform_data.netbird_oidc_application_recreate]
  }
}

resource "zitadel_user_grant" "walnuts_netbird_user" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.netbird.id
  user_id    = local.zitadel_human_user_ids.walnuts
  role_keys  = [zitadel_project_role.netbird_user.role_key]
}

output "netbird_oidc_client_id" {
  value       = nonsensitive(zitadel_application_oidc.netbird.client_id) // client_idは公開しても問題ない
  description = "Client ID for NetBird's ZITADEL identity-provider connector"
}

output "netbird_oidc_client_secret" {
  value       = zitadel_application_oidc.netbird.client_secret
  sensitive   = true
  description = "Client secret for NetBird's ZITADEL identity-provider connector"
}
