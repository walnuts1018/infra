terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.71.0"
    }
  }
}

provider "tfe" {
}
