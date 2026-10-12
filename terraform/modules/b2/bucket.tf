resource "b2_bucket" "minio_biscuit_backup" {
  bucket_name = "walnuts-minio-biscuit-backup-81f18e5"
  bucket_type = "allPrivate"

  lifecycle_rules {
    file_name_prefix              = ""
    days_from_hiding_to_deleting  = 1
    days_from_uploading_to_hiding = 0
  }
}

resource "b2_bucket" "horse_backup" {
  bucket_name = "walnuts-horse-backup-81f18e5"
  bucket_type = "allPrivate"

  default_server_side_encryption {
    algorithm = "AES256"
    mode      = "SSE-B2"
  }

  file_lock_configuration {
    is_file_lock_enabled = true

    default_retention {
      mode = "governance"

      period {
        duration = 30
        unit     = "days"
      }
    }
  }

  lifecycle_rules {
    file_name_prefix              = "horse/"
    days_from_uploading_to_hiding = 30
    days_from_hiding_to_deleting  = 7
  }

  lifecycle {
    prevent_destroy = true
  }
}
