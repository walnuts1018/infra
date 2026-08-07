module "onepassword" {
  source = "./modules/onepassword"

  vault                  = var.onepassword_vault
  service_account_token  = var.onepassword_service_account_token
  akvorado_client_id     = module.zitadel.akvorado_oidc_client_id
  akvorado_client_secret = module.zitadel.akvorado_oidc_client_secret
  b2_application_key     = module.b2.application_key.application_key
  headlamp_client_id     = module.zitadel.headlamp_oidc_client_id
  headlamp_client_secret = module.zitadel.headlamp_oidc_client_secret
  hubble_client_id       = module.zitadel.hubble_oidc_client_id
  hubble_client_secret   = module.zitadel.hubble_oidc_client_secret
  ipu_client_id          = module.zitadel.ipu_oauth2_proxy_client_id
  ipu_client_secret      = module.zitadel.ipu_oauth2_proxy_client_secret
  longhorn_client_id     = module.zitadel.longhorn_oidc_client_id
  longhorn_client_secret = module.zitadel.longhorn_oidc_client_secret
  netbird_setup_key      = module.netbird.kubernetes_router_setup_key
  netbox_client_id       = module.zitadel.netbox_oidc_client_id
  netbox_client_secret   = module.zitadel.netbox_oidc_client_secret
  oekaki_client_id       = module.zitadel.oekaki_oidc_client_id
  oekaki_client_secret   = module.zitadel.oekaki_oidc_client_secret
  pinniped_client_id     = module.zitadel.pinniped_oidc_client_id
  pinniped_client_secret = module.zitadel.pinniped_oidc_client_secret
  shumoku_client_id      = module.zitadel.shumoku_oidc_client_id
  shumoku_client_secret  = module.zitadel.shumoku_oidc_client_secret
}
