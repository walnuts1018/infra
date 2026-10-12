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

resource "b2_application_key" "horse_backup_writer" {
  key_name    = "horse-backup-writer"
  bucket_ids  = [b2_bucket.horse_backup.id]
  name_prefix = "horse/"
  capabilities = [
    "listFiles",
    "readFiles",
    "writeFiles",
  ]
}

resource "b2_application_key" "horse_backup_reader" {
  key_name    = "horse-backup-reader"
  bucket_ids  = [b2_bucket.horse_backup.id]
  name_prefix = "horse/"
  capabilities = [
    "listFiles",
    "readFiles",
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

output "horse_backup_credentials" {
  value = {
    bucket_name = b2_bucket.horse_backup.bucket_name
    writer = {
      application_key_id = b2_application_key.horse_backup_writer.application_key_id
      application_key    = b2_application_key.horse_backup_writer.application_key
    }
    reader = {
      application_key_id = b2_application_key.horse_backup_reader.application_key_id
      application_key    = b2_application_key.horse_backup_reader.application_key
    }
  }
  sensitive = true
}
