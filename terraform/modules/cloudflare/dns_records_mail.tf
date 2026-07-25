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
  content  = "feedback-smtp.ap-northeast-1.amazonses.com"
  type     = "MX"
  priority = 10
  ttl      = 600
  proxied  = false
}

resource "cloudflare_dns_record" "spf_mail_walnuts_dev" {
  zone_id = cloudflare_zone.walnuts_dev.id
  name    = "mail.walnuts.dev"
  content = "\"v=spf1 include:amazonses.com ~all\""
  type    = "TXT"
  ttl     = 600
  proxied = false
}
