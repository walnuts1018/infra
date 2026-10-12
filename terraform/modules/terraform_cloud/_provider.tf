terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.82.0"
    }
  }
}

variable "google_cloud_workload_provider_name" { type = string }
variable "google_cloud_plan_service_account_email" { type = string }
variable "google_cloud_apply_service_account_email" { type = string }
