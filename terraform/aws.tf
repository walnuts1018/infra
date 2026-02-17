module "aws" {
  source = "./modules/aws"
}

output "amazonses_verification_token_walnuts_dev" {
  value = module.aws.amazonses_verification_token_walnuts_dev
}

output "amazonses_dkim_tokens_walnuts_dev" {
  value = module.aws.ses_dkim_tokens_walnuts_dev
}
