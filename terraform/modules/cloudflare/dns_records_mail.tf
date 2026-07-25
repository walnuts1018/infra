# ----------------------------------------------
# Domain authentication
# ----------------------------------------------

resource "cloudflare_dns_record" "spf_walnuts_dev" {
  zone_id = cloudflare_zone.walnuts_dev.id
  name    = "walnuts.dev"
  content = "v=spf1 include:amazonses.com -all"
  type    = "TXT"
  ttl     = 600
  proxied = false
}

resource "cloudflare_dns_record" "dmarc_walnuts_dev" {
  zone_id = cloudflare_zone.walnuts_dev.id
  name    = "_dmarc.walnuts.dev"
  content = "v=DMARC1; p=quarantine; adkim=s; aspf=s; rua=mailto:dmarcreports@walnuts.dev"
  type    = "TXT"
  ttl     = 600
  proxied = false
}

# ----------------------------------------------
# Amazon SES outbound delivery
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
  count   = length(var.amazonses_dkim_tokens_walnuts_dev)
  zone_id = cloudflare_zone.walnuts_dev.id
  name    = "${var.amazonses_dkim_tokens_walnuts_dev[count.index]}._domainkey.walnuts.dev"
  content = "${var.amazonses_dkim_tokens_walnuts_dev[count.index]}.dkim.amazonses.com"
  type    = "CNAME"
  ttl     = 600
  proxied = false
}

# `mail.walnuts.dev` is reserved for SES's envelope sender and must not receive mail.
resource "cloudflare_dns_record" "amazonses_mail_from_mx_walnuts_dev" {
  zone_id  = cloudflare_zone.walnuts_dev.id
  name     = "mail.walnuts.dev"
  content  = "feedback-smtp.ap-northeast-1.amazonses.com"
  type     = "MX"
  priority = 10
  ttl      = 600
  proxied  = false
}

resource "cloudflare_dns_record" "spf_mail_walnuts_dev" {
  zone_id = cloudflare_zone.walnuts_dev.id
  name    = "mail.walnuts.dev"
  content = "v=spf1 include:amazonses.com -all"
  type    = "TXT"
  ttl     = 600
  proxied = false
}

# ----------------------------------------------
# Stalwart inbound delivery and client discovery
# ----------------------------------------------

resource "cloudflare_dns_record" "stalwart_a" {
  zone_id = cloudflare_zone.walnuts_dev.id
  name    = "mx.walnuts.dev"
  content = "111.100.165.117"
  type    = "A"
  ttl     = 600
  proxied = false
}

resource "cloudflare_dns_record" "mx_walnuts_dev" {
  zone_id  = cloudflare_zone.walnuts_dev.id
  name     = "walnuts.dev"
  content  = "mx.walnuts.dev"
  type     = "MX"
  priority = 10
  ttl      = 600
  proxied  = false
}

resource "cloudflare_dns_record" "srv_imaps" {
  zone_id  = cloudflare_zone.walnuts_dev.id
  name     = "_imaps._tcp.walnuts.dev"
  type     = "SRV"
  ttl      = 600
  priority = 10
  proxied  = false
  content  = "10 10 993 mx.walnuts.dev"
}

resource "cloudflare_dns_record" "srv_submission" {
  zone_id  = cloudflare_zone.walnuts_dev.id
  name     = "_submission._tcp.walnuts.dev"
  type     = "SRV"
  ttl      = 600
  priority = 10
  proxied  = false
  content  = "10 10 587 mx.walnuts.dev"
}

resource "cloudflare_dns_record" "srv_smtps" {
  zone_id  = cloudflare_zone.walnuts_dev.id
  name     = "_smtps._tcp.walnuts.dev"
  type     = "SRV"
  ttl      = 600
  priority = 10
  proxied  = false
  content  = "10 10 465 mx.walnuts.dev"
}
