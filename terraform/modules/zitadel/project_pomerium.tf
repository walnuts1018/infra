
resource "zitadel_project" "pomerium" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "Pomerium"
  project_role_assertion = true
}

resource "zitadel_project_role" "pomerium_longhorn_admin" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.pomerium.id
  role_key     = "longhorn-admin"
  display_name = "Longhorn Admin"
  group        = "Longhorn"
}

resource "zitadel_project_role" "pomerium_warrior_user" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.pomerium.id
  role_key     = "warrior-user"
  display_name = "Warrior User"
  group        = "Warrior"
}

resource "zitadel_project_role" "pomerium_hubble_user" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.pomerium.id
  role_key     = "hubble-user"
  display_name = "Hubble User"
  group        = "Hubble"
}

resource "zitadel_project_role" "pomerium_prometheus_user" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.pomerium.id
  role_key     = "prometheus-user"
  display_name = "Prometheus User"
  group        = "Prometheus"
}

resource "zitadel_project_role" "pomerium_oekaki_admin" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.pomerium.id
  role_key     = "oekaki-admin"
  display_name = "oekaki-admin"
  group        = "Oekaki Dengon Game"
}

resource "zitadel_application_oidc" "pomerium_app" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.pomerium.id
  name       = "pomerium"

  redirect_uris               = ["https://pomerium.walnuts.dev/oauth2/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = ["https://pomerium.walnuts.dev/.pomerium/signed_out"]
  additional_origins          = ["https://pomerium.walnuts.dev"]
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = false
  id_token_role_assertion     = false
  id_token_userinfo_assertion = false
}

resource "zitadel_user_grant" "walnuts_pomerium" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.pomerium.id
  user_id    = local.zitadel_human_user_ids.walnuts
  role_keys = [
    "longhorn-admin",
    "warrior-user",
    "hubble-user",
    "prometheus-user",
    "oekaki-admin",
  ]
}
