resource "aws_s3_bucket" "tempo" {
  bucket = format("tempo%s", var.bucket_name_suffix)
}

resource "aws_s3_bucket" "loki-chunks" {
  bucket = format("loki-chunks%s", var.bucket_name_suffix)
}

resource "aws_s3_bucket" "loki-ruler" {
  bucket = format("loki-ruler%s", var.bucket_name_suffix)
}

resource "aws_s3_bucket" "loki-admin" {
  bucket = format("loki-admin%s", var.bucket_name_suffix)
}


resource "aws_s3_bucket" "zalando-backup" {
  bucket = format("zalando-backup%s", var.bucket_name_suffix)
}


# data "aws_iam_policy_document" "toberepalaced" {
#   statement {
# principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }
#     actions = [
#       "s3:GetObject",
#     ]
#     resources = [
#       aws_s3_bucket.toberepalaced" {.arn,
#       "${aws_s3_bucket.toberepalaced" {.arn}/*",
#     ]
#   }
# }

# resource "aws_s3_bucket_policy" "toberepalaced" {{
#   bucket = aws_s3_bucket.toberepalaced" {.id
#   policy = data.aws_iam_policy_document.toberepalaced" {.json
# }
