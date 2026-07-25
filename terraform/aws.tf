module "aws" {
  source = "./modules/aws"
}

output "amazonses_verification_token_walnuts_dev" {
  value = module.aws.amazonses_verification_token_walnuts_dev
}

output "amazonses_dkim_tokens_walnuts_dev" {
  value = module.aws.ses_dkim_tokens_walnuts_dev
}

output "stalwart_ses_smtp_username" {
  value     = module.aws.stalwart_ses_smtp_username
  sensitive = true
}

output "stalwart_ses_smtp_password" {
  value     = module.aws.stalwart_ses_smtp_password
  sensitive = true
}
