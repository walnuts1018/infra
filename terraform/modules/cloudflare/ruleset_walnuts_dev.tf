# resource "cloudflare_ruleset" "configuration_rules_walnuts_dev" {
#   kind    = "zone"
#   name    = "default"
#   phase   = "http_config_settings"
#   zone_id = cloudflare_zone.walnuts_dev.id
#   rules = [
#     {
#       action      = "set_config"
#       description = "enable Rocket Loader"

#       expression = "(http.host eq \"walnuts.dev\") or (http.host eq \"minio.walnuts.dev\") or (http.host eq \"oekaki.walnuts.dev\")"
#       action_parameters = {
#         rocket_loader = true
#       }
#     },
#     {
#       action      = "set_config"
#       description = "disable zalaz"

#       expression = "(http.request.full_uri wildcard r\"https://hedgedoc.walnuts.dev/*\")"
#       action_parameters = {
#         disable_zaraz = true
#       }
#     }
#   ]
# }

# resource "cloudflare_ruleset" "cache_rules_walnuts_dev" {
#   kind    = "zone"
#   name    = "default"
#   phase   = "http_request_cache_settings"
#   zone_id = cloudflare_zone.walnuts_dev.id
#   rules = [
#     {
#       action      = "set_cache_settings"
#       description = "walnuts.dev"

#       expression = "(http.host eq \"walnuts.dev\") or (http.host eq \"oekaki.walnuts.dev\") or (http.host eq \"teddy.walnuts.dev\")"
#       action_parameters = {
#         cache = true
#       }
#     },
#     {
#       action      = "set_cache_settings"
#       description = "misskey"

#       expression = "(http.host eq \"misskey.walnuts.dev\" and starts_with(http.request.uri, \"/api/\"))"

#       action_parameters = {
#         cache = false
#       }
#     },
#     {
#       action      = "set_cache_settings"
#       description = "minio"

#       expression = "(http.host wildcard \"minio.walnuts.dev\") or (http.host wildcard \"minio-biscuit.walnuts.dev\")"
#       action_parameters = {
#         cache = false
#       }
#     }
#   ]
# }
