variable "minio_secret_key" {
  type = string
}

variable "cloudflare_api_token" {
  type    = string
}

terraform {
  backend "s3" {
    endpoints = {
      s3 = "http://localhost:9000"
    }
    bucket                      = "tf-state"
    key                         = "kurumi/terraform.tfstate"
    region                      = "us-east-1"

    access_key = "F1QPgAWk6bhvSrNjYPMS"
    # secret_key = "Vu9G6cKC7f41XrTIZURAoIhCpwkZwiBatluSPSZ4"

    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
    use_path_style            = true
  }
}
