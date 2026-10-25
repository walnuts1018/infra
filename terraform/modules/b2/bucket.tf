resource "b2_bucket" "minio_biscuit_backup" {
  bucket_name = "walnuts-minio-biscuit-backup-81f18e5"
  bucket_type = "allPrivate"

  lifecycle_rules {
    file_name_prefix              = ""
    days_from_hiding_to_deleting  = 1
    days_from_uploading_to_hiding = 0
  }
}

resource "b2_bucket" "mcl_playground_backup" {
  bucket_name = "walnuts-mcl-playground-backup-81f18e5"
  bucket_type = "allPrivate"

  lifecycle_rules {
    file_name_prefix              = ""
    days_from_hiding_to_deleting  = 30
    days_from_uploading_to_hiding = 365
  }
}
