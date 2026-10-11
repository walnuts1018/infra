terraform {
  required_version = "~> 1.16.0"

  required_providers {
    coderd = {
      source  = "coder/coderd"
      version = "0.0.30"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 7.24"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "3.0.0"
    }
  }

  cloud {
    organization = "walnuts-dev"

    workspaces {
      name = "infra"
    }
  }
}
