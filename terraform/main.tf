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
  required_version = "~>1.14.0"
  cloud {
    organization = "walnuts-dev"

    workspaces {
      name = "infra"
    }
  }
}
