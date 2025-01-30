resource "aws_s3_bucket" "tf-state" {
  bucket = format("tf-state%s", var.bucket_name_suffix)
}


resource "aws_s3_bucket_versioning" "tf-state" {
  bucket = aws_s3_bucket.tf-state.id
  versioning_configuration {
    status = "Enabled"
  }
}
