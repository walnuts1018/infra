resource "aws_s3_bucket" "loki-admin" {
  bucket = format("loki-admin%s", var.bucket_name_suffix)
}

resource "aws_s3_bucket" "loki-chunks" {
  bucket = format("loki-chunks%s", var.bucket_name_suffix)
}

resource "aws_s3_bucket" "loki-ruler" {
  bucket = format("loki-ruler%s", var.bucket_name_suffix)
}



resource "aws_s3_bucket" "mucaron" {
  bucket = format("mucaron%s", var.bucket_name_suffix)
}

resource "aws_s3_bucket" "tempo" {
  bucket = format("tempo%s", var.bucket_name_suffix)
}

resource "aws_s3_bucket" "zalando-backup" {
  bucket = format("zalando-backup%s", var.bucket_name_suffix)
}

resource "aws_s3_bucket" "mpeg-dash-encoder-source-upload" {
  bucket = format("mpeg-dash-encoder-source-upload%s", var.bucket_name_suffix)
}

resource "aws_s3_bucket" "mpeg-dash-encoder-output" {
  bucket = format("mpeg-dash-encoder-output%s", var.bucket_name_suffix)
}
