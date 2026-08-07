terraform {
  required_providers {
    onepassword = {
      source  = "1Password/onepassword"
      version = "3.3.1"
    }
  }
}

provider "onepassword" {
  service_account_token = var.service_account_token
}

variable "vault" {
  type        = string
  description = "UUID of the 1Password vault that contains Terraform-managed ExternalSecret values"
}

variable "service_account_token" {
  type        = string
  sensitive   = true
  description = "1Password service account token"
}

variable "akvorado_client_id" { type = string }

variable "akvorado_client_secret" {
  type      = string
  sensitive = true
}

variable "b2_application_key" {
  type      = string
  sensitive = true
}

variable "headlamp_client_id" { type = string }

variable "headlamp_client_secret" {
  type      = string
  sensitive = true
}
variable "hubble_client_id" { type = string }
variable "hubble_client_secret" {
  type      = string
  sensitive = true
}
variable "ipu_client_id" { type = string }
variable "ipu_client_secret" {
  type      = string
  sensitive = true
}
variable "longhorn_client_id" { type = string }
variable "longhorn_client_secret" {
  type      = string
  sensitive = true
}
variable "netbird_setup_key" {
  type      = string
  sensitive = true
}
variable "netbox_client_id" { type = string }
variable "netbox_client_secret" {
  type      = string
  sensitive = true
}
variable "oekaki_client_id" { type = string }
variable "oekaki_client_secret" {
  type      = string
  sensitive = true
}
variable "pinniped_client_id" { type = string }
variable "pinniped_client_secret" {
  type      = string
  sensitive = true
}
variable "shumoku_client_id" { type = string }
variable "shumoku_client_secret" {
  type      = string
  sensitive = true
}
