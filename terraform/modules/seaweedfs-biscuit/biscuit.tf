resource "aws_s3_bucket" "cloudnative_pg_backup" {
  bucket = "cloudnative-pg-backup"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "longhorn_backup" {
  bucket = "longhorn-backup"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "seaweedfs_default_backup" {
  bucket = "seaweedfs-default-backup"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "velero_backup" {
  bucket = "velero-backup"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "backup" {
  for_each = {
    cloudnative_pg = aws_s3_bucket.cloudnative_pg_backup
    longhorn       = aws_s3_bucket.longhorn_backup
    seaweedfs      = aws_s3_bucket.seaweedfs_default_backup
    velero         = aws_s3_bucket.velero_backup
  }

  bucket = each.value.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "app_managed_backup" {
  for_each = {
    cloudnative_pg = aws_s3_bucket.cloudnative_pg_backup
    longhorn       = aws_s3_bucket.longhorn_backup
    velero         = aws_s3_bucket.velero_backup
    # rclone sync mirrors deletions from seaweedfs-default into this bucket as
    # version transitions (current -> noncurrent), so this rule doubles as the
    # "restorable up to 30 days after deletion" retention for that bucket too.
    seaweedfs = aws_s3_bucket.seaweedfs_default_backup
  }

  bucket = each.value.id

  # These apps manage retention of their own current objects (Longhorn/CNPG/Velero
  # backup retention policies). This rule only garbage-collects what versioning
  # leaves behind: noncurrent versions created when an app overwrites or deletes
  # an object it still considers current.
  rule {
    id     = "gc-noncurrent-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
