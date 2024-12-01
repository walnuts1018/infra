resource "aws_s3_bucket" "loki-chunks" {
  bucket = format("loki-chunks%s", var.bucket_name_suffix)
}
