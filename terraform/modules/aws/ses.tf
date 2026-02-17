resource "aws_ses_domain_identity" "walnuts_dev" {
  domain = "walnuts.dev"
}

resource "aws_ses_domain_dkim" "ses_dkim" {
  domain = aws_ses_domain_identity.walnuts_dev.domain
}
