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

variable "service_account_token" {
  type      = string
  sensitive = true
}

variable "vault" {
  type = string
}

variable "gemini_free_api_key" {
  type      = string
  sensitive = true
}

variable "gemini_paid_api_key" {
  type      = string
  sensitive = true
}

variable "gemini_free_project_id" {
  type = string
}

variable "gemini_paid_project_id" {
  type = string
}
