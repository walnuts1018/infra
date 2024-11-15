terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.75.0"
    }
  }
}

variable "minio_secret_key" {
  type = string
}

provider "aws" {
  access_key                  = "709v82RovqXjvJR2P9yt"
  secret_key                  = var.minio_secret_key
  region                      = "ap-northeast-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  s3_use_path_style           = true

  endpoints {
    s3 = "https://minio.walnuts.dev"
  }
}
