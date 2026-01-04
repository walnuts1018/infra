module "zitadel" {
  source                = "./modules/zitadel"
  jwt_profile_json = var.zitadel_jwt_profile_json
}

import {
  id = "237477062321897835"
  to = module.zitadel.zitadel_org.ZITADEL
}

import {
  id = "237477822715658605"
  to = module.zitadel.zitadel_project.default
}
