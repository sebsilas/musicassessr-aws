output "api_base_url" {
  value = aws_api_gateway_deployment.this.invoke_url
}

output "s3_source_bucket" {
  value = aws_s3_bucket.source_bucket.bucket
}

output "s3_source_destination" {
  value = aws_s3_bucket.destination_bucket.bucket
}

output "aws_cognito_identity_pool" {
  value = aws_cognito_identity_pool.shiny_app.id
}