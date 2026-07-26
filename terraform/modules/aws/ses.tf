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

data "aws_iam_policy_document" "stalwart_ses_smtp" {
  statement {
    actions = ["ses:SendRawEmail"]

    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "ses:FromAddress"
      values   = ["*@${aws_ses_domain_identity.walnuts_dev.domain}"]
    }
  }
}

resource "aws_iam_user" "stalwart_ses_smtp" {
  name = "stalwart-ses-smtp"
}

resource "aws_iam_user_policy" "stalwart_ses_smtp" {
  name   = "ses-send-raw-email"
  user   = aws_iam_user.stalwart_ses_smtp.name
  policy = data.aws_iam_policy_document.stalwart_ses_smtp.json
}

resource "aws_iam_access_key" "stalwart_ses_smtp" {
  user = aws_iam_user.stalwart_ses_smtp.name
}

output "stalwart_ses_smtp_username" {
  value     = aws_iam_access_key.stalwart_ses_smtp.id
  sensitive = true
}

output "stalwart_ses_smtp_password" {
  value     = aws_iam_access_key.stalwart_ses_smtp.ses_smtp_password_v4
  sensitive = true
}
