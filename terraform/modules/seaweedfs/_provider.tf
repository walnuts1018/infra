terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 6.63.0"
      configuration_aliases = [aws.biscuit]
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }
}

data "external" "workload_identity_token" {
  program = ["sh", "-c", "printf '{\"token\":\"%s\"}' \"$TFC_WORKLOAD_IDENTITY_TOKEN_SEAWEEDFS\""]
}

variable "biscuit_endpoint" {
  type        = string
  description = "SeaweedFS S3 endpoint for the biscuit backup cluster"
}

variable "biscuit_terraform_access_key" {
  type        = string
  sensitive   = true
  description = "SeaweedFS Terraform S3 access key for the biscuit backup bucket"
}

variable "biscuit_terraform_secret_key" {
  type        = string
  sensitive   = true
  description = "SeaweedFS Terraform S3 secret key for the biscuit backup bucket"
}
