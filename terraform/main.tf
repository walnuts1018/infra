terraform {
  required_version = "1.14.3"
  cloud {
    organization = "walnuts-dev"

    workspaces {
      name = "infra"
    }
  }
}
