terraform {
  required_version = "~>1.14.0"
  cloud {
    organization = "walnuts-dev"

    workspaces {
      name = "infra"
    }
  }
}
