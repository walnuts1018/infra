resource "random_password" "picca_graphql_query_signing_secret" {
  length  = 64
  special = false
}

// imgproxyのIMGPROXY_KEY/IMGPROXY_SALTはhexエンコードされた値である必要があるためrandom_idを使う
resource "random_id" "picca_imgproxy_key" {
  byte_length = 32
}

resource "random_id" "picca_imgproxy_salt" {
  byte_length = 32
}

resource "random_password" "picca_redis_password" {
  length  = 32
  special = false
}

resource "random_password" "picca_rabbitmq_password" {
  length  = 32
  special = false
}

resource "random_password" "visual_regression_tracker_jwt_secret" {
  length  = 32
  special = false
}

resource "random_password" "visual_regression_tracker_admin_password" {
  length  = 24
  special = false
}

resource "random_password" "visual_regression_tracker_admin_api_key" {
  length  = 32
  special = false
}

resource "random_password" "radar_auth_secret" {
  length  = 64
  special = false
}

resource "onepassword_item" "external_secret" {
  vault    = var.vault
  title    = "terraform-external-secrets"
  category = "login"

  section_map = {
    terraform = {
      field_map = {
        "akvorado-client-id"                 = { type = "STRING", value = var.akvorado_client_id }
        "akvorado-client-secret"             = { type = "CONCEALED", value = var.akvorado_client_secret }
        "argocd-cli-client-id"               = { type = "STRING", value = var.argocd_cli_client_id }
        "b2-application-key"                 = { type = "CONCEALED", value = var.b2_application_key }
        "hubble-client-id"                   = { type = "STRING", value = var.hubble_client_id }
        "hubble-client-secret"               = { type = "CONCEALED", value = var.hubble_client_secret }
        "ipu-client-id"                      = { type = "STRING", value = var.ipu_client_id }
        "ipu-client-secret"                  = { type = "CONCEALED", value = var.ipu_client_secret }
        "longhorn-client-id"                 = { type = "STRING", value = var.longhorn_client_id }
        "longhorn-client-secret"             = { type = "CONCEALED", value = var.longhorn_client_secret }
        "netbird-setup-key"                  = { type = "CONCEALED", value = var.netbird_setup_key }
        "netbox-oidc-client-id"              = { type = "STRING", value = var.netbox_client_id }
        "netbox-oidc-client-secret"          = { type = "CONCEALED", value = var.netbox_client_secret }
        "oekaki-client-id"                   = { type = "STRING", value = var.oekaki_client_id }
        "oekaki-client-secret"               = { type = "CONCEALED", value = var.oekaki_client_secret }
        "opencost-client-id"                 = { type = "STRING", value = var.opencost_client_id }
        "opencost-client-secret"             = { type = "CONCEALED", value = var.opencost_client_secret }
        "picca-client-id"                    = { type = "STRING", value = var.picca_client_id }
        "picca-client-secret"                = { type = "CONCEALED", value = var.picca_client_secret }
        "picca-graphql-query-signing-secret" = { type = "CONCEALED", value = random_password.picca_graphql_query_signing_secret.result }
        "picca-imgproxy-key"                 = { type = "CONCEALED", value = random_id.picca_imgproxy_key.hex }
        "picca-imgproxy-salt"                = { type = "CONCEALED", value = random_id.picca_imgproxy_salt.hex }
        "picca-redis-password"               = { type = "CONCEALED", value = random_password.picca_redis_password.result }
        "picca-rabbitmq-password"            = { type = "CONCEALED", value = random_password.picca_rabbitmq_password.result }
        "radar-auth-secret"                  = { type = "CONCEALED", value = random_password.radar_auth_secret.result }
        "radar-client-id"                    = { type = "STRING", value = var.radar_client_id }
        "radar-client-secret"                = { type = "CONCEALED", value = var.radar_client_secret }
        "shumoku-client-id"                  = { type = "STRING", value = var.shumoku_client_id }
        "shumoku-client-secret"              = { type = "CONCEALED", value = var.shumoku_client_secret }

        "visual-regression-tracker-jwt-secret"     = { type = "CONCEALED", value = random_password.visual_regression_tracker_jwt_secret.result }
        "visual-regression-tracker-admin-password" = { type = "CONCEALED", value = random_password.visual_regression_tracker_admin_password.result }
        "visual-regression-tracker-admin-api-key"  = { type = "CONCEALED", value = random_password.visual_regression_tracker_admin_api_key.result }
      }
    }
  }
}
