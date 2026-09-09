resource "aws_s3_bucket" "biscuit_cloudnative_pg_backup" {
  provider = aws.biscuit
  bucket   = "cloudnative-pg-backup"

  lifecycle {
    prevent_destroy = true
  }
}
