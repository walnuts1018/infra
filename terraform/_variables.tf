variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "b2_application_key" {
  type      = string
  sensitive = true
}

variable "zitadel_jwt_profile_json" {
  type      = string
  sensitive = true
}

variable "oci_private_key" {
  type      = string
  sensitive = true
}

locals {
  seaweedfs_access_key = "terraform"
}

variable "seaweedfs_secret_key" {
  type      = string
  sensitive = true
}

variable "zitadel_google_idp_client_secret" {
  type        = string
  sensitive   = true
  description = "Google IDP OAuth2 Client Secret for ZITADEL"
}

# variable "zitadel_github_idp_client_secret" {
#   type        = string
#   sensitive   = true
#   description = "GitHub IDP OAuth2 Client Secret for ZITADEL"
# }
