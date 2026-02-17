resource "cloudflare_dns_record" "samba_walnuts_dev" {
  content = "192.168.0.132"
  name    = "samba.walnuts.dev"
  proxied = false
  ttl     = 1
  type    = "A"
  zone_id = cloudflare_zone.walnuts_dev.id
}

resource "cloudflare_dns_record" "kubeflow_walnuts_dev" {
  content = "10.228.155.184"
  name    = "kubeflow.walnuts.dev"
  proxied = false
  ttl     = 60
  type    = "A"
  zone_id = cloudflare_zone.walnuts_dev.id
}

resource "cloudflare_dns_record" "acme_challenge_kubeflow_walnuts_dev" {
  content = "0436db25-7ab7-4997-b764-fe78f3a6d7fe.auth.acme-dns.io"
  name    = "_acme-challenge.kubeflow.walnuts.dev"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  zone_id = cloudflare_zone.walnuts_dev.id
  settings = {
    flatten_cname = false
  }
}
resource "cloudflare_dns_record" "blog_walnuts_dev" {
  content = "hatenablog.com"
  name    = "blog.walnuts.dev"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  zone_id = cloudflare_zone.walnuts_dev.id
  settings = {
    flatten_cname = false
  }
}

resource "cloudflare_dns_record" "www_walnuts_dev" {
  content = "91a955e4-033a-4329-9cf2-882170b10dd4.cfargotunnel.com"
  name    = "www.walnuts.dev"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  zone_id = cloudflare_zone.walnuts_dev.id
  settings = {
    flatten_cname = false
  }
}


resource "cloudflare_dns_record" "visual_studio_marketplace_walnuts_dev" {
  content = "\"81a38dcc-dcaf-4c0c-b029-b215d8a3c67c\""
  name    = "_visual-studio-marketplace-walnuts1018.walnuts.dev"
  proxied = false
  ttl     = 1
  type    = "TXT"
  zone_id = cloudflare_zone.walnuts_dev.id
}

resource "cloudflare_dns_record" "keybase_site_verification_walnuts_dev" {
  content = "\"keybase-site-verification=CkunNoJNOAwbF99otCunfL3q8pI-kjr-VYLMUQYPz80\""
  name    = "walnuts.dev"
  proxied = false
  ttl     = 1
  type    = "TXT"
  zone_id = cloudflare_zone.walnuts_dev.id
}

resource "cloudflare_dns_record" "google_site_verification_walnuts_dev" {
  content = "\"google-site-verification=Wjs9Wr9Jf_kvXEiGrailsCoTttvnsrZJGc-gXEbKq3E\""
  name    = "walnuts.dev"
  proxied = false
  ttl     = 3600
  type    = "TXT"
  zone_id = cloudflare_zone.walnuts_dev.id
}
