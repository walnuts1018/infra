terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.8.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}
