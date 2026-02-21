terraform {
  required_providers {
    b2 = {
      source  = "Backblaze/b2"
      version = "0.12.1"
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
