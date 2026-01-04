module "zitadel" {
  source           = "./modules/zitadel"
  jwt_profile_json = var.zitadel_jwt_profile_json
}

moved {
  from = module.zitadel.zitadel_project.default
  to   = module.zitadel.zitadel_project.walnuts_dev
}
