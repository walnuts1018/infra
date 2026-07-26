module "zitadel" {
  source                   = "./modules/zitadel"
  jwt_profile_json         = var.zitadel_jwt_profile_json
  google_idp_client_secret = var.zitadel_google_idp_client_secret
  # github_idp_client_secret = var.zitadel_github_idp_client_secret
}

import {
  to = module.zitadel.zitadel_organization_domain.walnuts_dev
  id = "237477062321897835:walnuts.dev"
}

import {
  to = module.zitadel.zitadel_organization_domain.kmc_gr_jp
  id = "237477062321897835:kmc.gr.jp"
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
