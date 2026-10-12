terraform {
  required_providers {
    onepassword = {
      source  = "1Password/onepassword"
      version = "3.3.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.1"
    }
  }
}

provider "onepassword" {
  service_account_token = var.service_account_token
}

variable "service_account_token" {
  type      = string
  sensitive = true
}

variable "vault" {
  type = string
}
