resource "zitadel_project" "walnuts_dev" {
  org_id                 = zitadel_org.ZITADEL.id
  name                   = "walnuts.dev"
  project_role_assertion = true
}

resource "zitadel_project_member" "walnuts_dev_zitadel_admin" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.walnuts_dev.id
  user_id    = zitadel_human_user.zitadel_admin.id
  roles      = ["PROJECT_OWNER"]
}

resource "zitadel_project_role" "walnuts_dev_admin" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "admin"
  display_name = "admin"
}

resource "zitadel_project_role" "walnuts_dev_nextcloud_admin" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "nextcloud-admin"
  display_name = "nextcloud-admin"
  group        = "nextcloud"
}


resource "zitadel_project_role" "walnuts_dev_victoria_metrics" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "victoria-metrics"
  display_name = "victoria-metrics"
}

resource "zitadel_project_role" "walnuts_dev_sweets_rebellion" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "sweets-rebellion"
  display_name = "sweets-rebellion"
}

resource "zitadel_project_role" "walnuts_dev_nextcloud_pro" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "nextcloud-pro"
  display_name = "NextCloud PRO User"
}

resource "zitadel_project_role" "walnuts_dev_oekaki_admin" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "oekaki-admin"
  display_name = "oekaki-admin"
}

resource "zitadel_project_role" "walnuts_dev_hedgedoc_user" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "hedgedoc-user"
  display_name = "hedgedoc-user"
}

resource "zitadel_project_role" "walnuts_dev_dashy" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "dashy"
  display_name = "dashy"
}

resource "zitadel_project_role" "walnuts_dev_grafana_editor" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "grafana-editor"
  display_name = "grafana-editor"
  group        = "grafana"
}

resource "zitadel_project_role" "walnuts_dev_grafana_viewer" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "grafana-viewer"
  display_name = "grafana-viewer"
  group        = "grafana"
}

resource "zitadel_project_role" "walnuts_dev_kibana_admin" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "kibana-admin"
  display_name = "kibana-admin"
}

resource "zitadel_project_role" "walnuts_dev_zalando_admin" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "zalando-admin"
  display_name = "zalando-admin "
  group        = "zalando"
}

resource "zitadel_project_role" "walnuts_dev_ac_hacking_admin" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "ac-hacking-admin"
  display_name = "ac-hacking-admin"
}

resource "zitadel_project_role" "walnuts_dev_archivebox" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "archivebox"
  display_name = "archivebox"
}

resource "zitadel_project_role" "walnuts_dev_prometheus_admin" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "prometheus-admin"
  display_name = "prometheus-admin"
}

resource "zitadel_project_role" "walnuts_dev_minio_console_admin" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "minio-consoleAdmin"
  display_name = "MinIO Console Admin"
}

resource "zitadel_project_role" "walnuts_dev_hubble_admin" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "hubble-admin"
  display_name = "hubble-admin"
}

resource "zitadel_project_role" "walnuts_dev_argocd_admin" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "argocd-admin"
  display_name = "argocd-admin"
  group        = "argocd"
}

resource "zitadel_project_role" "walnuts_dev_openclarity_admin" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "openclarity-admin"
  display_name = "openclarity-admin"
  group        = "openclarity"
}

resource "zitadel_project_role" "walnuts_dev_teddy_admin" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "teddy-admin"
  display_name = "teddy-admin"
  group        = "teddy"
}

resource "zitadel_project_role" "walnuts_dev_teddy_ryokohbato" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "teddy-ryokohbato"
  display_name = "teddy-ryokohbato"
  group        = "teddy"
}

resource "zitadel_project_role" "walnuts_dev_teddy_segre" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "teddy-segre"
  display_name = "teddy-segre"
  group        = "teddy"
}

resource "zitadel_project_role" "walnuts_dev_teddy_crash" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "teddy-crash"
  display_name = "teddy-crash"
  group        = "teddy"
}

resource "zitadel_project_role" "walnuts_dev_teddy_akikaze" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "teddy-akikaze"
  display_name = "teddy-akikaze"
  group        = "teddy"
}

resource "zitadel_project_role" "walnuts_dev_teddy_cicada" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "teddy-cicada"
  display_name = "teddy-cicada"
  group        = "teddy"
}

resource "zitadel_project_role" "walnuts_dev_warrior" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "warrior"
  display_name = "warrior"
  group        = "warrior"
}

resource "zitadel_project_role" "walnuts_dev_adguard_admin" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "adguard-admin"
  display_name = "adguard-admin"
  group        = "adguard"
}

resource "zitadel_project_role" "walnuts_dev_argocd_viewer" {
  org_id       = zitadel_org.ZITADEL.id
  project_id   = zitadel_project.walnuts_dev.id
  role_key     = "argocd-viewer"
  display_name = "argocd-viewer"
  group        = "argocd"
}

resource "zitadel_application_oidc" "walnuts_dev_komga" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.walnuts_dev.id
  name       = "komga"

  redirect_uris               = ["https://komga.walnuts.dev/login/oauth2/code/zitadel"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = []
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = false
  id_token_role_assertion     = false
  id_token_userinfo_assertion = false
}


resource "zitadel_application_oidc" "walnuts_dev_teddy" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.walnuts_dev.id
  name       = "teddy"

  redirect_uris = [
    "http://localhost:3000/api/auth/callback/zitadel",
    "https://teddy.walnuts.dev/api/auth/callback/zitadel",
  ]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = []
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = true
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = false
  id_token_role_assertion     = false
  id_token_userinfo_assertion = true
}

resource "zitadel_application_oidc" "walnuts_dev_test" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.walnuts_dev.id
  name       = "test"

  redirect_uris               = ["https://meisai.local.hatena.sh/api/v1/login/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = []
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = false
  id_token_role_assertion     = false
  id_token_userinfo_assertion = false
}

resource "zitadel_application_oidc" "walnuts_dev_openclarity" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.walnuts_dev.id
  name       = "openclarity"

  redirect_uris               = ["https://openclarity.walnuts.dev/oauth2/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = []
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = false
  id_token_role_assertion     = false
  id_token_userinfo_assertion = false
}

resource "zitadel_application_oidc" "walnuts_dev_openchokin_legacy" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.walnuts_dev.id
  name       = "OpenChokin"

  redirect_uris = [
    "http://192.168.0.13:3000/api/auth/callback/zitadel",
    "https://openchokin.walnuts.dev/api/auth/callback/zitadel",
    "http://localhost:3000/api/auth/callback/zitadel",
  ]
  response_types = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types = [
    "OIDC_GRANT_TYPE_AUTHORIZATION_CODE",
    "OIDC_GRANT_TYPE_REFRESH_TOKEN",
  ]
  auth_method_type = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris = [
    "https://openchokin.walnuts.dev",
    "http://192.168.0.13:3000/",
  ]
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = false
  id_token_role_assertion     = false
  id_token_userinfo_assertion = false
}

resource "zitadel_application_oidc" "walnuts_dev_warrior" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.walnuts_dev.id
  name       = "warrior"

  redirect_uris               = ["https://warrior.walnuts.dev/oauth2/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = []
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = false
  id_token_role_assertion     = false
  id_token_userinfo_assertion = false
}

resource "zitadel_application_oidc" "walnuts_dev_adguard" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.walnuts_dev.id
  name       = "adguard"

  redirect_uris               = ["https://private-dns.walnuts.dev/oauth2/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = []
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = false
  id_token_role_assertion     = false
  id_token_userinfo_assertion = false
}

resource "zitadel_application_oidc" "walnuts_dev_jmw" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.walnuts_dev.id
  name       = "jmw"

  redirect_uris               = []
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = []
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = false
  id_token_role_assertion     = false
  id_token_userinfo_assertion = false
}

resource "zitadel_application_oidc" "walnuts_dev_argocd" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.walnuts_dev.id
  name       = "argocd"

  redirect_uris = [
    "https://argocd.walnuts.dev/auth/callback",
    "https://argocd-biscuit.walnuts.dev/auth/callback",
    "https://argocd.local.walnuts.dev/auth/callback",
  ]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  post_logout_redirect_uris   = []
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = false
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = true
  id_token_role_assertion     = false
  id_token_userinfo_assertion = true
}

resource "zitadel_user_grant" "zitadel_admin_walnuts_dev_admin" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.walnuts_dev.id
  user_id    = zitadel_human_user.zitadel_admin.id
  role_keys  = [zitadel_project_role.walnuts_dev_admin.role_key]
}

resource "zitadel_user_grant" "rh_98_walnuts_dev" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.walnuts_dev.id
  user_id    = local.zitadel_human_user_ids.rh_98
  role_keys  = []
}

resource "zitadel_user_grant" "latticeheart_walnuts_dev" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.walnuts_dev.id
  user_id    = local.zitadel_human_user_ids.latticeheart
  role_keys  = []
}

resource "zitadel_user_grant" "walnuts_walnuts_dev" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.walnuts_dev.id
  user_id    = local.zitadel_human_user_ids.walnuts
  role_keys = [
    zitadel_project_role.walnuts_dev_admin.role_key,
    zitadel_project_role.walnuts_dev_nextcloud_admin.role_key,
    zitadel_project_role.walnuts_dev_victoria_metrics.role_key,
    zitadel_project_role.walnuts_dev_oekaki_admin.role_key,
    zitadel_project_role.walnuts_dev_hedgedoc_user.role_key,
    zitadel_project_role.walnuts_dev_dashy.role_key,
    zitadel_project_role.walnuts_dev_kibana_admin.role_key,
    zitadel_project_role.walnuts_dev_zalando_admin.role_key,
    zitadel_project_role.walnuts_dev_ac_hacking_admin.role_key,
    zitadel_project_role.walnuts_dev_archivebox.role_key,
    zitadel_project_role.walnuts_dev_prometheus_admin.role_key,
    zitadel_project_role.walnuts_dev_minio_console_admin.role_key,
    zitadel_project_role.walnuts_dev_hubble_admin.role_key,
    zitadel_project_role.walnuts_dev_argocd_admin.role_key,
    zitadel_project_role.walnuts_dev_openclarity_admin.role_key,
    zitadel_project_role.walnuts_dev_teddy_admin.role_key,
    zitadel_project_role.walnuts_dev_warrior.role_key,
    zitadel_project_role.walnuts_dev_adguard_admin.role_key,
  ]
}

resource "zitadel_user_grant" "tawara_ryota_walnuts_dev" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.walnuts_dev.id
  user_id    = local.zitadel_human_user_ids.tawara_ryota
  role_keys  = [
    zitadel_project_role.walnuts_dev_grafana_viewer.role_key,
    zitadel_project_role.walnuts_dev_argocd_viewer.role_key,
  ]
}

resource "zitadel_user_grant" "junya_walnuts_dev" {
  org_id     = zitadel_org.ZITADEL.id
  project_id = zitadel_project.walnuts_dev.id
  user_id    = local.zitadel_human_user_ids.junya
  role_keys  = [
    zitadel_project_role.walnuts_dev_grafana_viewer.role_key,
    zitadel_project_role.walnuts_dev_argocd_viewer.role_key,
  ]
}
