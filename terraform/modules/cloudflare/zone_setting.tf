resource "cloudflare_zone_settings_override" "walnuts_dev" {
  zone_id = cloudflare_zone.walnuts_dev.id
  settings {
    always_online = "on"
    rocket_loader = "off"
    speed_brain = "on"
    early_hints = "on"
  }
}
