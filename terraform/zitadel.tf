module "zitadel" {
  source                   = "./modules/zitadel"
  jwt_profile_json         = var.zitadel_jwt_profile_json
  google_idp_client_secret = var.zitadel_google_idp_client_secret
  # github_idp_client_secret = var.zitadel_github_idp_client_secret
}

output "netbird_oidc_client_id" {
  value       = module.zitadel.netbird_oidc_client_id
  description = "Client ID for NetBird's ZITADEL identity-provider connector"
}

output "netbird_oidc_client_secret" {
  value       = module.zitadel.netbird_oidc_client_secret
  sensitive   = true
  description = "Client secret for NetBird's ZITADEL identity-provider connector"
}

output "stalwart_oidc_client_id" {
  value       = nonsensitive(module.zitadel.stalwart_oidc_client_id) // client_idは公開しても問題ない
  description = "Client ID for Stalwart's ZITADEL OpenID Connect directory"
}

output "shumoku_oidc_client_id" {
  value       = nonsensitive(module.zitadel.shumoku_oidc_client_id)
  description = "Client ID for Shumoku's Envoy Gateway OIDC policy"
}

output "shumoku_oidc_client_secret" {
  value       = module.zitadel.shumoku_oidc_client_secret
  sensitive   = true
  description = "Store this in 1Password item shumoku as client_secret"
}

output "headlamp_oidc_client_id" {
  value       = nonsensitive(module.zitadel.headlamp_oidc_client_id)
  description = "Client ID for Headlamp's ZITADEL OIDC login"
}

output "headlamp_oidc_client_secret" {
  value       = module.zitadel.headlamp_oidc_client_secret
  sensitive   = true
  description = "Store this in 1Password item headlamp as client_secret"
}

output "pinniped_oidc_client_id" {
  value       = nonsensitive(module.zitadel.pinniped_oidc_client_id)
  description = "Client ID for Pinniped Supervisor's ZITADEL upstream OIDC client"
}

output "pinniped_oidc_client_secret" {
  value       = module.zitadel.pinniped_oidc_client_secret
  sensitive   = true
  description = "Client secret for Pinniped Supervisor's ZITADEL upstream OIDC client"
}

output "terraform_cloud_saml_metadata_url" {
  value       = module.zitadel.terraform_cloud_saml_metadata_url
  description = "Zitadel SAML metadata URL for Terraform Cloud"
}
