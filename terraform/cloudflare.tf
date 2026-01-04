module "cloudflare" {
  source               = "./modules/cloudflare"
  cloudflare_api_token = var.cloudflare_api_token
}

locals {
  account_id = "38b5eab012d216dfcc52dcd69e7764b5"
  zone_id    = "48b02398c8bc932f4d0b1dba83de196c"
}
