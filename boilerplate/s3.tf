locals {
  s3_source_bucket_name      = "shinny-app-source-41630"
  s3_destination_bucket_name = "shinny-app-destination-41630"

}


resource "aws_s3_bucket" "source_bucket" {
  bucket        = local.s3_source_bucket_name

  versioning {
    enabled = true
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "POST", "PUT"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

  tags = local.tags
}


resource "aws_s3_bucket" "destination_bucket" {
  bucket        = local.s3_destination_bucket_name
  versioning {
    enabled = true
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "POST", "PUT"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

  tags = local.tags
}


resource "aws_lambda_permission" "source_bucket" {
  statement_id  = "AllowExecutionFromS3DestBucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sonic_pyin_v2.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.source_bucket.arn
}

resource "aws_s3_bucket_notification" "aws_s3_bucket_notification" {
  bucket = aws_s3_bucket.source_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.sonic_pyin_v2.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".wav"
  }

  depends_on = [aws_lambda_permission.source_bucket]
}
