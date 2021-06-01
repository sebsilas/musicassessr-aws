resource "random_integer" "rand" {
  min = 10000
  max = 99999
}


locals {
  s3_source_bucket_name      = "${var.project_name}-source-${random_integer.rand.result}"
  s3_destination_bucket_name = "${var.project_name}-destination-${random_integer.rand.result}"

}


resource "aws_s3_bucket" "source_bucket" {
  bucket        = local.s3_source_bucket_name
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET","HEAD","POST","PUT"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

  tags = local.tags
}


resource "aws_s3_bucket" "destination_bucket" {
  bucket        = local.s3_destination_bucket_name
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET","HEAD","POST","PUT"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
  
  tags = local.tags
}
