terraform {
  required_version = "~> 1.16.0"

  cloud {
    organization = "walnuts-dev"

    workspaces {
      name = "infra"
    }
  }
}
