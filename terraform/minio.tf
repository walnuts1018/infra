# locals {
#   minio_access_key = "L2thlqrcs0RnPD6YP61w"
# }

# module "minio" {
#   source             = "./modules/minio"
#   bucket_name_suffix = ""
#   minio_access_key   = local.minio_access_key
#   minio_secret_key   = var.minio_secret_key
# }

# import {
#   id = "loki-chunks"
#   to = module.minio.aws_s3_bucket.loki-chunks
# }
