resource "aws_s3_bucket" "loki-admin" {
  bucket = "loki-admin"
}

resource "aws_s3_bucket" "loki-chunks" {
  bucket = "loki-chunks"
}

resource "aws_s3_bucket" "loki-ruler" {
  bucket = "loki-ruler"
}
