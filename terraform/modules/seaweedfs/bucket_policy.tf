locals {
  desired_state = jsondecode(file("${path.module}/../../../k8s/apps/seaweedfs-default/_configs/desired-state.json"))
  public_read_buckets = {
    for bucket in local.desired_state.buckets : bucket.name => bucket
    if length(bucket.publicRead) > 0
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
