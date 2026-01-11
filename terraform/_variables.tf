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
