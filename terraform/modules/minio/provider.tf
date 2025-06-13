terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100.0"
    }
  }
}

variable "minio_access_key" {
  type = string
}

variable "minio_secret_key" {
  type = string
}

provider "aws" {
  access_key                  = var.minio_access_key
  secret_key                  = var.minio_secret_key
  region                      = "ap-northeast-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  s3_use_path_style           = true

  endpoints {
    s3 = "http://localhost:9000"
  }
}
