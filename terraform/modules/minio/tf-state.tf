resource "aws_s3_bucket" "tf-state" {
  bucket = format("tf-state%s", var.bucket_name_suffix)
}
