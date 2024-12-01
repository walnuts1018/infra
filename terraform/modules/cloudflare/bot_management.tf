resource "cloudflare_bot_management" "terraform_managed_resource_48b02398c8bc932f4d0b1dba83de196c" {
  ai_bots_protection = "disabled"
  enable_js          = false
  fight_mode         = false
  zone_id            = var.zone_id
}
