resource "cloudflare_ruleset" "terraform_managed_resource_304092e7f9904942998f39441eb19203" {
  kind    = "zone"
  name    = "default"
  phase   = "http_config_settings"
  zone_id = cloudflare_zone.walnuts_dev.id
  rules {
    action      = "set_config"
    description = "enable Rocket Loader"
    enabled     = true
    expression  = "(http.host eq \"walnuts.dev\") or (http.host eq \"minio.walnuts.dev\") or (http.host eq \"oekaki.walnuts.dev\")"
    ref         = "9c1ef58603494a50af7855c3263e6bdf"

    action_parameters {
      rocket_loader = true
    }
  }
}

resource "cloudflare_ruleset" "terraform_managed_resource_d3a7c2d6242d41068be770b71e25b365" {
  kind    = "zone"
  name    = "default"
  phase   = "http_request_cache_settings"
  zone_id = cloudflare_zone.walnuts_dev.id

  rules {
    action      = "set_cache_settings"
    description = "walnuts.dev"
    enabled     = true
    expression  = "(http.host eq \"walnuts.dev\")  or (http.host eq \"oekaki.walnuts.dev\")"
    ref         = "02afb6686434455195ad5e1d630a099d"

    action_parameters {
      cache = true
    }
  }

  rules {
    action      = "set_cache_settings"
    description = "misskey"
    enabled     = true
    expression  = "(http.host eq \"misskey.walnuts.dev\" and starts_with(http.request.uri, \"/api/\"))"
    ref         = "e6dbe87b1b2b483db3df88b5576deb03"

    action_parameters {
      cache = false
    }
  }

  rules {
    action      = "set_cache_settings"
    description = "minio"
    enabled     = true
    expression  = "(http.host wildcard \"minio.walnuts.dev\")"
    ref         = "9f4de8f107314fbe8058a07b62e1ffcd"

    action_parameters {
      cache = false
    }
  }
}
