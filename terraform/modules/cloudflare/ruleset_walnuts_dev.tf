resource "cloudflare_ruleset" "configuration_rules_walnuts_dev" {
  kind    = "zone"
  name    = "default"
  phase   = "http_config_settings"
  zone_id = cloudflare_zone.walnuts_dev.id
  rules = [
    {
      action      = "set_config"
      description = "enable Rocket Loader"
      enabled     = true
      ref         = "9c1ef58603494a50af7855c3263e6bdf"

      expression = "(http.host eq \"walnuts.dev\") or (http.host eq \"minio.walnuts.dev\") or (http.host eq \"oekaki.walnuts.dev\")"
      action_parameters = {
        rocket_loader = true
      }
    },
    {
      action      = "set_config"
      description = "disable zalaz"
      enabled     = true
      ref         = "f828c6290c354dec96cff72dd0d17005"

      expression = "(http.request.full_uri wildcard r\"https://hedgedoc.walnuts.dev/*\")"
      action_parameters = {
        disable_zaraz = true
      }
    }
  ]
}

resource "cloudflare_ruleset" "cache_rules_walnuts_dev" {
  kind    = "zone"
  name    = "default"
  phase   = "http_request_cache_settings"
  zone_id = cloudflare_zone.walnuts_dev.id
  rules = [
    {
      action      = "set_cache_settings"
      description = "walnuts.dev"
      enabled     = true
      ref         = "02afb6686434455195ad5e1d630a099d"

      expression = "(http.host eq \"walnuts.dev\") or (http.host eq \"oekaki.walnuts.dev\") or (http.host eq \"maple.walnuts.dev\")"
      action_parameters = {
        cache = true
      }
    },
    {
      action      = "set_cache_settings"
      description = "misskey"
      enabled     = true
      ref         = "e6dbe87b1b2b483db3df88b5576deb03"

      expression = "(http.host eq \"misskey.walnuts.dev\" and starts_with(http.request.uri, \"/api/\"))"

      action_parameters = {
        cache = false
      }
    },
    {
      action      = "set_cache_settings"
      description = "minio"
      enabled     = true
      ref         = "9f4de8f107314fbe8058a07b62e1ffcd"

      expression = "(http.host wildcard \"minio.walnuts.dev\") or (http.host wildcard \"minio-biscuit.walnuts.dev\")"
      action_parameters = {
        cache = false
      }
    }
  ]
}
