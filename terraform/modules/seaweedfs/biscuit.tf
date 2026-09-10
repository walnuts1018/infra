resource "aws_s3_bucket" "biscuit_cloudnative_pg_backup" {
  provider = aws.biscuit
  bucket   = "cloudnative-pg-backup"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "biscuit_longhorn_backup" {
  provider = aws.biscuit
  bucket   = "longhorn-backup"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "biscuit_seaweedfs_default_backup" {
  provider = aws.biscuit
  bucket   = "seaweedfs-default-backup"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "biscuit_velero_backup" {
  provider = aws.biscuit
  bucket   = "velero-backup"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "biscuit_backup" {
  for_each = {
    cloudnative_pg = aws_s3_bucket.biscuit_cloudnative_pg_backup
    longhorn       = aws_s3_bucket.biscuit_longhorn_backup
    seaweedfs      = aws_s3_bucket.biscuit_seaweedfs_default_backup
    velero         = aws_s3_bucket.biscuit_velero_backup
  }

  provider = aws.biscuit
  bucket   = each.value.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "biscuit_backup" {
  for_each = {
    seaweedfs = aws_s3_bucket.biscuit_seaweedfs_default_backup
  }

  provider = aws.biscuit
  bucket   = each.value.id

  rule {
    id     = "retain-seaweedfs-backups-for-30-days"
    status = "Enabled"

    filter {}

    expiration {
      days = 30
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
