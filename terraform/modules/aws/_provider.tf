terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.99.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}
