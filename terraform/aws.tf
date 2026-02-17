module "aws" {
  source = "./modules/aws"
}

output "amazonses_verification_token" {
  value = module.aws.amazonses_verification_token
}
