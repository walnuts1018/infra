module "cloudflare" {
  source                       = "./modules/cloudflare"
  cloudflare_api_token         = var.cloudflare_api_token
  amazonses_verification_token = module.aws.amazonses_verification_token
}
