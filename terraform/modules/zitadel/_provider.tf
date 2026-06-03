terraform {
  required_providers {
    zitadel = {
      source  = "zitadel/zitadel"
      version = "2.12.8"
    }
  }
}

variable "jwt_profile_json" {
  type      = string
  sensitive = true
}

variable "google_idp_client_secret" {
  type        = string
  sensitive   = true
  description = "Google IDP OAuth2 Client Secret (Instance-level IDP: 260968596954415251)"
}

# variable "github_idp_client_secret" {
#   type        = string
#   sensitive   = true
#   description = "GitHub IDP OAuth2 Client Secret (Org-level IDP: 240667268147577736)"
# }

provider "zitadel" {
  domain           = "auth.walnuts.dev"
  insecure         = false
  port             = "443"
  jwt_profile_json = var.jwt_profile_json
}
