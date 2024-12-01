locals {
  minio_access_key   = "L2thlqrcs0RnPD6YP61w"
}

module "minio" {
  source             = "../modules/minio"
  bucket_name_suffix = ""
  minio_access_key   = local.minio_access_key
  minio_secret_key   = var.minio_secret_key
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
