terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.16.0"
    }
  }
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "amazonses_verification_token_walnuts_dev" {
  type = string
}

variable "amazonses_dkim_tokens_walnuts_dev" {
  type = list(string)
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
