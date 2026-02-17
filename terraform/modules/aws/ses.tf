resource "aws_ses_domain_identity" "walnuts_dev" {
  domain = "walnuts.dev"
}

output "amazonses_verification_token_walnuts_dev" {
  value = aws_ses_domain_identity.walnuts_dev.verification_token
}

resource "aws_ses_domain_dkim" "walnuts_dev" {
  domain = aws_ses_domain_identity.walnuts_dev.domain
}

output "ses_dkim_tokens_walnuts_dev" {
  value = aws_ses_domain_dkim.walnuts_dev.dkim_tokens
}

resource "aws_ses_domain_identity_verification" "verification_walnuts_dev" {
  domain = aws_ses_domain_identity.walnuts_dev.domain
}

resource "aws_ses_domain_mail_from" "walnuts_dev" {
  domain           = aws_ses_domain_identity.walnuts_dev.domain
  mail_from_domain = "mail.${aws_ses_domain_identity.walnuts_dev.domain}"
}
