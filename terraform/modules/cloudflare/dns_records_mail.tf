# ----------------------------------------------
# SPF / DKIM / DMARC
# ----------------------------------------------

resource "cloudflare_dns_record" "spf_walnuts_dev" {
  zone_id = cloudflare_zone.walnuts_dev.id
  name    = "walnuts.dev"
  content = "v=spf1 include:amazonses.com include:_spf.mx.cloudflare.net ~all"
  type    = "TXT"
  ttl     = 600
  proxied = false
}

resource "cloudflare_dns_record" "dmarc" {
  zone_id = cloudflare_zone.walnuts_dev.id
  name    = "_dmarc.walnuts.dev"
  content = "v=DMARC1; p=none; rua=mailto:dmarcreports@walnuts.dev;"
  type    = "TXT"
  ttl     = 1
  proxied = false
}

# ----------------------------------------------
# Cloudflare Email Routing
# ----------------------------------------------

resource "cloudflare_dns_record" "mx_cloudflare_1_walnuts_dev" {
  content  = "route1.mx.cloudflare.net"
  name     = "walnuts.dev"
  priority = 110
  proxied  = false
  ttl      = 1
  type     = "MX"
  zone_id  = cloudflare_zone.walnuts_dev.id
}

resource "cloudflare_dns_record" "mx_cloudflare_2_walnuts_dev" {
  content  = "route2.mx.cloudflare.net"
  name     = "walnuts.dev"
  priority = 120
  proxied  = false
  ttl      = 1
  type     = "MX"
  zone_id  = cloudflare_zone.walnuts_dev.id
}

resource "cloudflare_dns_record" "mx_cloudflare_3_walnuts_dev" {
  content  = "route3.mx.cloudflare.net"
  name     = "walnuts.dev"
  priority = 130
  proxied  = false
  ttl      = 1
  type     = "MX"
  zone_id  = cloudflare_zone.walnuts_dev.id
}

resource "cloudflare_dns_record" "dkim_cloudflare_walnuts_dev" {
  zone_id = cloudflare_zone.walnuts_dev.id
  name    = "cf2024-1._domainkey.walnuts.dev"
  content = "\"v=DKIM1; h=sha256; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAiweykoi+o48IOGuP7GR3X0MOExCUDY/BCRHoWBnh3rChl7WhdyCxW3jgq1daEjPPqoi7sJvdg5hEQVsgVRQP4DcnQDVjGMbASQtrY4WmB1VebF+RPJB2ECPsEDTpeiI5ZyUAwJaVX7r6bznU67g7LvFq35yIo4sdlmtZGV+i0H4cpYH9+3JJ78k\" \"m4KXwaf9xUJCWF6nxeD+qG6Fyruw1Qlbds2r85U9dkNDVAS3gioCvELryh1TxKGiVTkg4wqHTyHfWsp7KD3WQHYJn0RyfJJu6YEmL77zonn7p2SRMvTMP3ZEXibnC9gz3nnhR6wcYL8Q7zXypKTMD58bTixDSJwIDAQAB\""
  type    = "TXT"
  ttl     = 1
  proxied = false
}

# ----------------------------------------------
# Amazon SES
# ----------------------------------------------

resource "cloudflare_dns_record" "amazonses_verification_record_walnuts_dev" {
  zone_id = cloudflare_zone.walnuts_dev.id
  name    = "_amazonses.walnuts.dev"
  content = var.amazonses_verification_token_walnuts_dev
  type    = "TXT"
  ttl     = 600
  proxied = false
}

resource "cloudflare_dns_record" "amazonses_dkim_walnuts_dev" {
  count   = 3
  zone_id = cloudflare_zone.walnuts_dev.id
  name    = "${var.amazonses_dkim_tokens_walnuts_dev[count.index]}._domainkey.walnuts.dev"
  type    = "CNAME"
  ttl     = 600
  proxied = false
  content = "${var.amazonses_dkim_tokens_walnuts_dev[count.index]}.dkim.amazonses.com"
}

resource "cloudflare_dns_record" "amazonses_mail_from_mx_walnuts_dev" {
  zone_id  = cloudflare_zone.walnuts_dev.id
  name     = "mail.walnuts.dev"
  content  = "10 feedback-smtp.ap-northeast-1.amazonses.com"
  type     = "MX"
  priority = 100
  ttl      = 600
  proxied  = false
}

resource "cloudflare_dns_record" "spf_mail_walnuts_dev" {
  zone_id = cloudflare_zone.walnuts_dev.id
  name    = "mail.walnuts.dev"
  content = "v=spf1 include:amazonses.com ~all"
  type    = "TXT"
  ttl     = 600
  proxied = false
}
