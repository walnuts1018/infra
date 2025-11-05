resource "b2_bucket" "minio_biscuit_backup" {
  bucket_name = "walnuts-minio-biscuit-backup-81f18e5"
  bucket_type = "allPrivate"
}
