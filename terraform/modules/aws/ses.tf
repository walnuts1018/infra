resource "aws_ses_domain_identity" "walnuts_dev" {
  domain = "walnuts.dev"
}

resource "aws_ses_domain_dkim" "ses_dkim" {
  domain = aws_ses_domain_identity.walnuts_dev.domain
}

output "amazonses_verification_token" {
  value = aws_ses_domain_identity.walnuts_dev.verification_token
}

resource "aws_ses_domain_identity_verification" "verification_walnuts_dev" {
  domain = aws_ses_domain_identity.walnuts_dev.domain
}
