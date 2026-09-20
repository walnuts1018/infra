terraform {
  required_version = "~> 1.15.0"
  cloud {
    organization = "walnuts-dev"

    workspaces {
      name = "infra"
    }
  }
}
