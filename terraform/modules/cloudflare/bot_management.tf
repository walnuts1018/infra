resource "cloudflare_bot_management" "walnuts_dev" {
  ai_bots_protection    = "disabled"
  cf_robots_variant     = "policy_only"
  crawler_protection    = "disabled"
  enable_js             = false
  fight_mode            = false
  is_robots_txt_managed = false
  zone_id               = cloudflare_zone.walnuts_dev.id
}

resource "cloudflare_bot_management" "waln_uk" {
  ai_bots_protection    = "disabled"
  cf_robots_variant     = "policy_only"
  crawler_protection    = "disabled"
  enable_js             = false
  fight_mode            = false
  is_robots_txt_managed = false
  zone_id               = cloudflare_zone.waln_uk.id
}
