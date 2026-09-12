terraform {
  required_version = "~> 1.15.0"

  cloud {
    organization = "walnuts-dev"

    workspaces {
      name = "seaweedfs-biscuit"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.63.0"
    }
  }
}

variable "seaweedfs_biscuit_terraform_access_key" {
  type        = string
  sensitive   = true
  description = "SeaweedFS biscuit Terraform S3 access key"
}

variable "seaweedfs_biscuit_terraform_secret_key" {
  type        = string
  sensitive   = true
  description = "SeaweedFS biscuit Terraform S3 secret key"
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = var.seaweedfs_biscuit_terraform_access_key
  secret_key                  = var.seaweedfs_biscuit_terraform_secret_key
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  s3_use_path_style           = true

  endpoints {
    s3  = "https://seaweedfs-biscuit.local.walnuts.dev"
    sts = "https://seaweedfs-biscuit.local.walnuts.dev"
  }
}

module "seaweedfs_biscuit" {
  source = "../modules/seaweedfs-biscuit"
}
