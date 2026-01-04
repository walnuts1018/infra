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

output "application_key" {
  value = b2_application_key.minio_biscuit_backup
}
