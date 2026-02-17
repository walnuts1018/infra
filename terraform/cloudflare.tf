module "cloudflare" {
  source                                   = "./modules/cloudflare"
  cloudflare_api_token                     = var.cloudflare_api_token
  amazonses_verification_token_walnuts_dev = module.aws.amazonses_verification_token_walnuts_dev
  amazonses_dkim_tokens_walnuts_dev        = module.aws.ses_dkim_tokens_walnuts_dev
}
