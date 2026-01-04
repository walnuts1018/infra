resource "cloudflare_email_routing_settings" "walnuts_dev" {
  zone_id = cloudflare_zone.walnuts_dev.id
}
