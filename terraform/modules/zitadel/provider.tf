terraform {
  required_providers {
    zitadel = {
      source  = "zitadel/zitadel"
      version = "2.0.1"
    }
  }
}

variable "jwt_profile_file_path" {
  type = string
}

provider "zitadel" {
  domain           = "localhost"
  insecure         = "true"
  port             = "8080"
  jwt_profile_file = var.jwt_profile_file_path
}
