module "zitadel" {
  source           = "./modules/zitadel"
  jwt_profile_json = var.zitadel_jwt_profile_json
}
