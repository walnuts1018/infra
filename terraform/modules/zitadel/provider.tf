terraform {
  required_providers {
    zitadel = {
      source  = "zitadel/zitadel"
      version = "2.2.0"
    }
  }
}

variable "jwt_profile_file_path" {
  type = string
}

provider "zitadel" {
  domain           = "auth.walnuts.dev"
  insecure         = "false"
  port             = "443"
  jwt_profile_file = var.jwt_profile_file_path
}
