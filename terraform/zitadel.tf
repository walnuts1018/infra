module "zitadel" {
  source                   = "./modules/zitadel"
  jwt_profile_json         = var.zitadel_jwt_profile_json
  google_idp_client_secret = var.zitadel_google_idp_client_secret
  # github_idp_client_secret = var.zitadel_github_idp_client_secret
}

moved {
  from = module.zitadel.zitadel_project.default
  to   = module.zitadel.zitadel_project.walnuts_dev
}

removed {
  from = module.zitadel.zitadel_domain.walnuts_dev

  lifecycle {
    destroy = false
  }
}

removed {
  from = module.zitadel.zitadel_domain.kmc_gr_jp

  lifecycle {
    destroy = false
  }
}

import {
  to = module.zitadel.zitadel_organization_domain.walnuts_dev
  id = "walnuts.dev:237477062321897835"
}

import {
  to = module.zitadel.zitadel_organization_domain.kmc_gr_jp
  id = "kmc.gr.jp:237477062321897835"
}
