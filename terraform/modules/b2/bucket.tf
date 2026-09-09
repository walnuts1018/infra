resource "b2_bucket" "minio_biscuit_backup" {
  bucket_name = "walnuts-minio-biscuit-backup-81f18e5"
  bucket_type = "allPrivate"

  lifecycle_rules {
    file_name_prefix              = ""
    days_from_hiding_to_deleting  = 1
    days_from_uploading_to_hiding = 0
  }
}

resource "b2_bucket" "seaweedfs_biscuit_backup" {
  bucket_name = "walnuts-seaweedfs-biscuit-backup-81f18e5"
  bucket_type = "allPrivate"

  lifecycle_rules {
    file_name_prefix             = ""
    days_from_hiding_to_deleting = 30
    # Keep unchanged objects readable. Replaced versions are hidden by B2
    # automatically and retained for 30 days.
    days_from_uploading_to_hiding = 0
  }
}
