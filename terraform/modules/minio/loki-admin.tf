resource "aws_s3_bucket" "loki-admin" {
  bucket = format("loki-admin%s", var.bucket_name_suffix)
}
