resource "aws_s3_bucket" "backup-default" {
  bucket = format("backup-db0b3ca7-fd16-47d0-8a2a-038479708854%s", var.bucket_name_suffix)
}
