terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.76.0"
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

module "minio" {
  source             = "../modules/minio"
  bucket_name_suffix = ""
}

import {
  id = "loki-admin"
  to = module.minio.aws_s3_bucket.loki-admin
}

import {
  id = "loki-chunks"
  to = module.minio.aws_s3_bucket.loki-chunks
}

import {
  id = "loki-ruler"
  to = module.minio.aws_s3_bucket.loki-ruler
}

import {
  id = "oekaki-dengon-game"
  to = module.minio.aws_s3_bucket.oekaki-dengon-game
}

import {
  id = "mucaron"
  to = module.minio.aws_s3_bucket.mucaron
}

import {
  id = "tempo"
  to = module.minio.aws_s3_bucket.tempo
}

import {
  id = "zalando-backup"
  to = module.minio.aws_s3_bucket.zalando-backup
}
