variable "cloudflare_api_token" {
  type = string
}

variable "b2_application_key" {
  type = string
}

variable "zitadel_jwt_profile_json" {
  type = string
}

terraform {
  cloud {
    organization = "walnuts-dev"

    workspaces {
      name = "infra"
    }
  }
}
