terraform {
  required_version = ">= 1.0.0"
  required_providers {
    b2 = {
      source = "Backblaze/b2"
    }
  }
}

variable "application_key" {
  type      = string
  sensitive = true
}

variable "application_key_id" {
  type = string
}

provider "b2" {
  application_key_id = var.application_key_id
  application_key    = var.application_key
}
