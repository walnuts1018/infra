resource "zitadel_project" "netbox" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "netbox"
  project_role_assertion = true
}

resource "zitadel_project_role" "netbox_admin" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.netbox.id
  role_key     = "netbox-admin"
  display_name = "NetBox Admin"
}

resource "zitadel_application_oidc" "netbox" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.netbox.id
  name       = "netbox"

  redirect_uris               = ["https://netbox.walnuts.dev/oauth/complete/oidc/"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = ["https://netbox.walnuts.dev/"]
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_JWT"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
}

resource "zitadel_user_grant" "walnuts_netbox" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.netbox.id
  user_id    = local.zitadel_human_user_ids.walnuts
  role_keys  = ["netbox-admin"]
}

output "netbox_oidc_client_id" {
  value       = zitadel_application_oidc.netbox.client_id
  description = "Set this as clientID in k8s/apps/netbox/securitypolicy.jsonnet"
}

output "netbox_oidc_client_secret" {
  value       = zitadel_application_oidc.netbox.client_secret
  sensitive   = true
  description = "Store this in 1Password as 'netbox.oidc-client-secret'"
}

output "netbox_project_id" {
  value       = zitadel_project.netbox.id
  description = "Set this as <project-id> in k8s/apps/netbox/securitypolicy.jsonnet"
}
