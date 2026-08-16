locals {
  desired_state = jsondecode(file("${path.module}/../../../k8s/apps/seaweedfs-default/_configs/desired-state.json"))
  public_read_buckets = {
    for bucket in local.desired_state.buckets : bucket.name => bucket
    if length(bucket.publicRead) > 0
  }
  cors_buckets = {
    for bucket in local.desired_state.buckets : bucket.name => bucket
    if length(lookup(bucket, "cors", [])) > 0
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  for_each = local.public_read_buckets

  bucket = each.key
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for object_key in each.value.publicRead : {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${each.key}/${object_key}"
      }
    ]
  })
}

resource "aws_s3_bucket_cors_configuration" "this" {
  for_each = local.cors_buckets

  bucket = each.key

  dynamic "cors_rule" {
    for_each = each.value.cors
    content {
      allowed_origins = cors_rule.value.allowedOrigins
      allowed_methods = cors_rule.value.allowedMethods
      allowed_headers = lookup(cors_rule.value, "allowedHeaders", null)
      expose_headers  = lookup(cors_rule.value, "exposeHeaders", null)
      max_age_seconds = lookup(cors_rule.value, "maxAgeSeconds", null)
    }
  }
}
