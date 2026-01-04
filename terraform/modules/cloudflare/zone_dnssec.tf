resource "cloudflare_zone_dnssec" "walnuts_dev" {
  status  = "active"
  zone_id = cloudflare_zone.walnuts_dev.id
}

resource "cloudflare_zone_dnssec" "waln_uk" {
  status  = "disabled"
  zone_id = cloudflare_zone.waln_uk.id
}
