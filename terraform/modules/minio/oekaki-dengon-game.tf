resource "aws_s3_bucket" "oekaki-dengon-game" {
  bucket = format("oekaki-dengon-game%s", var.bucket_name_suffix)
}

resource "aws_s3_bucket_policy" "oekaki-dengon-game" {
  bucket = aws_s3_bucket.oekaki-dengon-game.bucket
  policy = data.aws_iam_policy_document.oekaki-dengon-game.json
}

data "aws_iam_policy_document" "oekaki-dengon-game" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:GetBucketLocation", "s3:ListBucket"]
    resources = [aws_s3_bucket.oekaki-dengon-game.arn]
  }

  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.oekaki-dengon-game.arn}/*"]
  }
}
