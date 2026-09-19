terraform {
  required_providers {
    coderd = {
      source  = "coder/coderd"
      version = "= 0.0.23"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.63.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9"
    }
  }
}
