module "zitadel" {
  source                   = "./modules/zitadel"
  jwt_profile_json         = var.zitadel_jwt_profile_json
  google_idp_client_secret = var.zitadel_google_idp_client_secret
  # github_idp_client_secret = var.zitadel_github_idp_client_secret
}

output "netbird_oidc_client_id" {
  value       = module.zitadel.netbird_oidc_client_id
  description = "Store in 1Password as netbird.oidc-client-id"
}
