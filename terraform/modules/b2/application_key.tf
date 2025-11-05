resource "b2_application_key" "minio_biscuit_backup" {
  key_name  = "minio-biscuit-backup"
  bucket_id = b2_bucket.minio_biscuit_backup.id
  capabilities = [
    "deleteFiles",
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
