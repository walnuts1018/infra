terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.24"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "3.0.0"
    }
  }
}

variable "billing_account_id" { type = string }

locals {
  free_project_id = "walnuts-horse-gemini-free"
  paid_project_id = "walnuts-horse-gemini-paid"
}

data "google_client_config" "this" {}

data "google_billing_account" "gemini_paid" {
  billing_account = var.billing_account_id
  open            = true
  lookup_projects = false

  lifecycle {
    postcondition {
      condition     = self.currency_code == "JPY"
      error_message = "500円のSpend CapにはJPYの請求先アカウントが必要です。"
    }
  }
}

provider "restapi" {
  uri                  = "https://billingbudgets.googleapis.com"
  bearer_token         = data.google_client_config.this.access_token
  write_returns_object = true
  debug                = false

  headers = {
    "Content-Type"        = "application/json"
    "x-goog-user-project" = local.paid_project_id
  }
}
