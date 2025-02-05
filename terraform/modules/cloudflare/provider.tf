terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.52.0"
    }
  }
}

variable "cloudflare_api_token" {
  type = string
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
