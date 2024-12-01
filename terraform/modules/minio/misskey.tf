resource "aws_s3_bucket" "misskey" {
  bucket = format("misskey%s", var.bucket_name_suffix)
}

resource "aws_s3_bucket_policy" "misskey" {
  bucket = aws_s3_bucket.misskey.bucket
  policy = data.aws_iam_policy_document.misskey.json
}

data "aws_iam_policy_document" "misskey" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:GetBucketLocation", "s3:ListBucket"]
    resources = [aws_s3_bucket.misskey.arn]
  }

  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.misskey.arn}/*"]
  }
}
