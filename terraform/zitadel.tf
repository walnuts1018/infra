module "zitadel" {
  source                   = "./modules/zitadel"
  jwt_profile_json         = var.zitadel_jwt_profile_json
  google_idp_client_secret = var.zitadel_google_idp_client_secret
  # github_idp_client_secret = var.zitadel_github_idp_client_secret
}

import {
  to = module.zitadel.zitadel_domain.walnuts_dev
  id = "walnuts.dev"
}

import {
  to = module.zitadel.zitadel_domain.kmc_gr_jp
  id = "kmc.gr.jp"
}
