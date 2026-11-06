module "netbird" {
  source                = "./modules/netbird"
  management_token      = var.netbird_management_token
  zitadel_client_id     = module.zitadel.netbird_oidc_client_id
  zitadel_client_secret = module.zitadel.netbird_oidc_client_secret
}
