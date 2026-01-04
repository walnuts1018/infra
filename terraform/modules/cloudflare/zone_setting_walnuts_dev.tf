resource "cloudflare_zone_setting" "always_online" {
  zone_id    = cloudflare_zone.walnuts_dev.id
  setting_id = "always_online"
  value      = "on"
}
