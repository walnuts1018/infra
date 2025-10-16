terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.17.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}
