resource "b2_application_key" "minio_biscuit_backup" {
  key_name   = "minio-biscuit-backup"
  bucket_ids = [b2_bucket.minio_biscuit_backup.id]
  capabilities = [
    "deleteFiles",
    "listAllBucketNames",
    "listBuckets",
    "listFiles",
    "readBucketEncryption",
    "readBucketLogging",
    "readBucketNotifications",
    "readBucketReplications",
    "readBuckets",
    "readFiles",
    "shareFiles",
    "writeBucketEncryption",
    "writeBucketLogging",
    "writeBucketNotifications",
    "writeBucketReplications",
    "writeBuckets",
    "writeFiles"
  ]
}

resource "b2_application_key" "mcl_playground_backup" {
  key_name   = "mcl-playground-backup"
  bucket_ids = [b2_bucket.mcl_playground_backup.id]
  capabilities = [
    "listBuckets",
    "listFiles",
    "readFiles",
    "writeFiles",
  ]
}

output "application_key" {
  value = {
    application_key_id = b2_application_key.minio_biscuit_backup.application_key_id
    application_key    = b2_application_key.minio_biscuit_backup.application_key
    key_name           = b2_application_key.minio_biscuit_backup.key_name
    bucket_ids         = b2_application_key.minio_biscuit_backup.bucket_ids
    capabilities       = b2_application_key.minio_biscuit_backup.capabilities
  }
  sensitive = true
}

output "mcl_playground_backup_application_key" {
  value = {
    application_key_id = b2_application_key.mcl_playground_backup.application_key_id
    application_key    = b2_application_key.mcl_playground_backup.application_key
    key_name           = b2_application_key.mcl_playground_backup.key_name
    bucket_ids         = b2_application_key.mcl_playground_backup.bucket_ids
    capabilities       = b2_application_key.mcl_playground_backup.capabilities
  }
  sensitive = true
}
