terraform {
  required_providers {
    zitadel = {
      source  = "zitadel/zitadel"
      version = "2.6.5"
    }
  }
}

variable "jwt_profile_json" {
  type      = string
  sensitive = true
}

provider "zitadel" {
  domain           = "auth.walnuts.dev"
  insecure         = "false"
  port             = "443"
  jwt_profile_json = var.jwt_profile_json
}
