variable "b2_application_key" {
  type      = string
  sensitive = true
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "netbird_management_token" {
  type      = string
  sensitive = true
}

variable "oci_private_key" {
  type      = string
  sensitive = true
}

variable "seaweedfs_secret_key" {
  type      = string
  sensitive = true
}

variable "zitadel_google_idp_client_secret" {
  type      = string
  sensitive = true
}

variable "zitadel_jwt_profile_json" {
  type      = string
  sensitive = true
}
