terraform {
  required_providers {
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
