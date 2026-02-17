resource "cloudflare_dns_record" "smtp_send_resend_walnuts_dev" {
  content  = "feedback-smtp.us-east-1.amazonses.com"
  name     = "send.resend.walnuts.dev"
  priority = 10
  proxied  = false
  ttl      = 1
  type     = "MX"
  zone_id  = cloudflare_zone.walnuts_dev.id
}

resource "cloudflare_dns_record" "mx_cloudflare_3_walnuts_dev" {
  content  = "route3.mx.cloudflare.net"
  name     = "walnuts.dev"
  priority = 33
  proxied  = false
  ttl      = 1
  type     = "MX"
  zone_id  = cloudflare_zone.walnuts_dev.id
}

resource "cloudflare_dns_record" "mx_cloudflare_2_walnuts_dev" {
  content  = "route2.mx.cloudflare.net"
  name     = "walnuts.dev"
  priority = 1
  proxied  = false
  ttl      = 1
  type     = "MX"
  zone_id  = cloudflare_zone.walnuts_dev.id
}

resource "cloudflare_dns_record" "mx_cloudflare_1_walnuts_dev" {
  content  = "route1.mx.cloudflare.net"
  name     = "walnuts.dev"
  priority = 12
  proxied  = false
  ttl      = 1
  type     = "MX"
  zone_id  = cloudflare_zone.walnuts_dev.id
}

resource "cloudflare_dns_record" "dkim_cloudflare_walnuts_dev" {
  content = "\"v=DKIM1; h=sha256; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAiweykoi+o48IOGuP7GR3X0MOExCUDY/BCRHoWBnh3rChl7WhdyCxW3jgq1daEjPPqoi7sJvdg5hEQVsgVRQP4DcnQDVjGMbASQtrY4WmB1VebF+RPJB2ECPsEDTpeiI5ZyUAwJaVX7r6bznU67g7LvFq35yIo4sdlmtZGV+i0H4cpYH9+3JJ78k\" \"m4KXwaf9xUJCWF6nxeD+qG6Fyruw1Qlbds2r85U9dkNDVAS3gioCvELryh1TxKGiVTkg4wqHTyHfWsp7KD3WQHYJn0RyfJJu6YEmL77zonn7p2SRMvTMP3ZEXibnC9gz3nnhR6wcYL8Q7zXypKTMD58bTixDSJwIDAQAB\""
  name    = "cf2024-1._domainkey.walnuts.dev"
  proxied = false
  ttl     = 1
  type    = "TXT"
  zone_id = cloudflare_zone.walnuts_dev.id
}

resource "cloudflare_dns_record" "dmarc" {
  content = "\"v=DMARC1; p=none; rua=mailto:5e9239fe52ad41fd850bd72545e1e484@dmarc-reports.cloudflare.net;\""
  name    = "_dmarc.walnuts.dev"
  proxied = false
  ttl     = 1
  type    = "TXT"
  zone_id = cloudflare_zone.walnuts_dev.id
}

resource "cloudflare_dns_record" "resend_domainkey_walnuts_dev" {
  content = "\"p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCUe5ntBGI0Xnq8SBPdRqtCD7ZFiI39jCB9NbSOatnYw8MufwpaLPBTMwKdPKKWx+w9Ytv8LRQo1hbj6vGfjPq5mZ1wJPcA6YontVaVpXrL933pb9FYDCzoS3apPsQe3aYsRYA/vjvp6IU19PTVq4NTnX9SFUHK5i7eD8qUlevpvwIDAQAB\""
  name    = "resend._domainkey.resend.walnuts.dev"
  proxied = false
  ttl     = 1
  type    = "TXT"
  zone_id = cloudflare_zone.walnuts_dev.id
}

resource "cloudflare_dns_record" "spf_send_resend_walnuts_dev" {
  content = "\"v=spf1 include:amazonses.com ~all\""
  name    = "send.resend.walnuts.dev"
  proxied = false
  ttl     = 1
  type    = "TXT"
  zone_id = cloudflare_zone.walnuts_dev.id
}

resource "cloudflare_dns_record" "spf_walnuts_dev" {
  content = "\"v=spf1 include:_spf.mx.cloudflare.net ~all\""
  name    = "walnuts.dev"
  proxied = false
  ttl     = 1
  type    = "TXT"
  zone_id = cloudflare_zone.walnuts_dev.id
}
