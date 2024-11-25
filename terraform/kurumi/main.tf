variable "minio_secret_key" {
  type = string
}

module "minio" {
  source             = "../modules/minio"
  bucket_name_suffix = ""
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

# module "zitadel" {
#   source = "../modules/zitadel"
#   jwt_profile_file_path = "zitadel.token"
# }

# import {
#   id = "237477062321897835"
#   to = module.zitadel.zitadel_org.ZITADEL
# }

# import {
#   id = "237477822715658605"
#   to = module.zitadel.zitadel_project.default
# }
