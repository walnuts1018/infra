resource "cloudflare_record" "samba" {
  content = "192.168.0.132"
  name    = "samba"
  proxied = false
  ttl     = 1
  type    = "A"
  zone_id = var.zone_id
}

resource "cloudflare_record" "resend_mx" {
  content  = "feedback-smtp.us-east-1.amazonses.com"
  name     = "send.resend"
  priority = 10
  proxied  = false
  ttl      = 1
  type     = "MX"
  zone_id = var.zone_id
}

resource "cloudflare_record" "terraform_managed_resource_3bcba7bd4b61fd21dbbf52d7164dd740" {
  content = "\"v=DMARC1; p=none; rua=mailto:5e9239fe52ad41fd850bd72545e1e484@dmarc-reports.cloudflare.net;\""
  name    = "_dmarc"
  proxied = false
  ttl     = 1
  type    = "TXT"
  zone_id = var.zone_id
}

resource "cloudflare_record" "terraform_managed_resource_52809b82fc5e93f5d20192f93b74f884" {
  content = "\"p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCUe5ntBGI0Xnq8SBPdRqtCD7ZFiI39jCB9NbSOatnYw8MufwpaLPBTMwKdPKKWx+w9Ytv8LRQo1hbj6vGfjPq5mZ1wJPcA6YontVaVpXrL933pb9FYDCzoS3apPsQe3aYsRYA/vjvp6IU19PTVq4NTnX9SFUHK5i7eD8qUlevpvwIDAQAB\""
  name    = "resend._domainkey.resend"
  proxied = false
  ttl     = 1
  type    = "TXT"
  zone_id = var.zone_id
}

resource "cloudflare_record" "terraform_managed_resource_7fcb19b7bea399e699d5f6af4fd265f7" {
  content = "\"v=spf1 include:amazonses.com ~all\""
  name    = "send.resend"
  proxied = false
  ttl     = 1
  type    = "TXT"
  zone_id = var.zone_id
}

resource "cloudflare_record" "terraform_managed_resource_b3aa52624d17e28a78c729cd51533e1b" {
  content = "\"v=spf1 include:_spf.mx.cloudflare.net ~all\""
  name    = "walnuts.dev"
  proxied = false
  ttl     = 1
  type    = "TXT"
  zone_id = var.zone_id
}

resource "cloudflare_record" "terraform_managed_resource_cb6d40bd779430bc5c123e3c6120cacc" {
  content = "\"keybase-site-verification=CkunNoJNOAwbF99otCunfL3q8pI-kjr-VYLMUQYPz80\""
  name    = "walnuts.dev"
  proxied = false
  ttl     = 1
  type    = "TXT"
  zone_id = var.zone_id
}

resource "cloudflare_record" "terraform_managed_resource_a95a9a38f2f9db38790102b666d980b3" {
  content = "\"google-site-verification=Wjs9Wr9Jf_kvXEiGrailsCoTttvnsrZJGc-gXEbKq3E\""
  name    = "walnuts.dev"
  proxied = false
  ttl     = 3600
  type    = "TXT"
  zone_id = var.zone_id
}
