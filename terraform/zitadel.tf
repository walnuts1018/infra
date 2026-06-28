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
