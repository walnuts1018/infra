terraform {
  required_providers {
    netbird = {
      source  = "netbirdio/netbird"
      version = "0.0.10"
    }
  }
}

variable "management_token" {
  type        = string
  sensitive   = true
  description = "NetBird Management API admin PAT used by Terraform"
}

variable "zitadel_client_id" {
  type        = string
  description = "OIDC client ID for NetBird's ZITADEL identity-provider connector"
}

variable "zitadel_client_secret" {
  type        = string
  sensitive   = true
  description = "OIDC client secret for NetBird's ZITADEL identity-provider connector"
}

provider "netbird" {
  management_url = "https://netbird.walnuts.dev"
  token          = var.management_token
}
