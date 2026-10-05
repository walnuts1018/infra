terraform {
  required_version = "~> 1.15.0"

  required_providers {
    coderd = {
      source  = "coder/coderd"
      version = "= 0.0.23"
    }
  }

  cloud {
    organization = "walnuts-dev"

    workspaces {
      name = "infra"
    }
  }
}
