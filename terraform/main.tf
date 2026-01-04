# variable "minio_secret_key" {
#   type = string
# }

variable "cloudflare_api_token" {
  type = string
}

variable "b2_application_key" {
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
