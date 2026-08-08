resource "zitadel_project" "kubernetes" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "Kubernetes"
  project_role_assertion = true
}

resource "zitadel_project_role" "kubernetes_cluster_admin" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.kubernetes.id
  role_key     = "cluster-admin"
  display_name = "Kubernetes Cluster Administrator"
}

resource "zitadel_user_grant" "walnuts_kubernetes_cluster_admin" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.kubernetes.id
  user_id    = local.zitadel_human_user_ids.walnuts
  role_keys  = [zitadel_project_role.kubernetes_cluster_admin.role_key]
}

resource "zitadel_application_oidc" "openunison" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.kubernetes.id
  name       = "OpenUnison"

  redirect_uris               = ["https://kubernetes.walnuts.dev/auth/oidc"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = ["https://kubernetes.walnuts.dev/"]
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_JWT"
  access_token_role_assertion = false
  id_token_role_assertion     = false
  id_token_userinfo_assertion = true
}

output "openunison_oidc_client_id" {
  value       = nonsensitive(zitadel_application_oidc.openunison.client_id)
  description = "Client ID for OpenUnison's ZITADEL login"
}

output "openunison_oidc_client_secret" {
  value       = zitadel_application_oidc.openunison.client_secret
  sensitive   = true
  description = "Client secret for OpenUnison's ZITADEL login"
}

output "kubernetes_project_id" {
  value       = nonsensitive(zitadel_project.kubernetes.id)
  description = "ZITADEL project ID used in Kubernetes group claims"
}

moved {
  from = zitadel_project.headlamp
  to   = zitadel_project.kubernetes
}

moved {
  from = zitadel_project_role.headlamp_user
  to   = zitadel_project_role.kubernetes_cluster_admin
}

moved {
  from = zitadel_user_grant.walnuts_headlamp
  to   = zitadel_user_grant.walnuts_kubernetes_cluster_admin
}

moved {
  from = zitadel_application_oidc.headlamp
  to   = zitadel_application_oidc.openunison
}
