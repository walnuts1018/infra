resource "random_password" "visual_regression_tracker_jwt_secret" {
  length  = 32
  special = false
}

resource "onepassword_item" "external_secret" {
  vault    = var.vault
  title    = "terraform-external-secrets"
  category = "login"

  section_map = {
    terraform = {
      field_map = {
        "akvorado-client-id"        = { type = "STRING", value = var.akvorado_client_id }
        "akvorado-client-secret"    = { type = "CONCEALED", value = var.akvorado_client_secret }
        "argocd-cli-client-id"      = { type = "STRING", value = var.argocd_cli_client_id }
        "b2-application-key"        = { type = "CONCEALED", value = var.b2_application_key }
        "headlamp-client-id"        = { type = "STRING", value = var.headlamp_client_id }
        "headlamp-client-secret"    = { type = "CONCEALED", value = var.headlamp_client_secret }
        "hubble-client-id"          = { type = "STRING", value = var.hubble_client_id }
        "hubble-client-secret"      = { type = "CONCEALED", value = var.hubble_client_secret }
        "ipu-client-id"             = { type = "STRING", value = var.ipu_client_id }
        "ipu-client-secret"         = { type = "CONCEALED", value = var.ipu_client_secret }
        "longhorn-client-id"        = { type = "STRING", value = var.longhorn_client_id }
        "longhorn-client-secret"    = { type = "CONCEALED", value = var.longhorn_client_secret }
        "netbird-setup-key"         = { type = "CONCEALED", value = var.netbird_setup_key }
        "netbox-oidc-client-id"     = { type = "STRING", value = var.netbox_client_id }
        "netbox-oidc-client-secret" = { type = "CONCEALED", value = var.netbox_client_secret }
        "oekaki-client-id"          = { type = "STRING", value = var.oekaki_client_id }
        "oekaki-client-secret"      = { type = "CONCEALED", value = var.oekaki_client_secret }
        "opencost-client-id"        = { type = "STRING", value = var.opencost_client_id }
        "opencost-client-secret"    = { type = "CONCEALED", value = var.opencost_client_secret }
        "shumoku-client-id"         = { type = "STRING", value = var.shumoku_client_id }
        "shumoku-client-secret"     = { type = "CONCEALED", value = var.shumoku_client_secret }

        "visual-regression-tracker-jwt-secret" = { type = "CONCEALED", value = random_password.visual_regression_tracker_jwt_secret.result }
      }
    }
  }
}
