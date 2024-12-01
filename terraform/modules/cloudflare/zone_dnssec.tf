resource "cloudflare_zone_dnssec" "walnuts_dev" {
  zone_id = cloudflare_zone.walnuts_dev.id
}
