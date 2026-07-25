terraform {
  required_providers {
    netbird = {
      source  = "netbirdio/netbird"
      version = "0.0.9"
    }
  }
}

variable "management_token" {
  type        = string
  sensitive   = true
  description = "NetBird Management API admin PAT used by Terraform"
}

provider "netbird" {
  management_url = "https://netbird.walnuts.dev"
  token          = var.management_token
}
