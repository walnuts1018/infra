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

variable "amazonses_verification_token" {
  type = string
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
