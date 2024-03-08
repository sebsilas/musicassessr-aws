resource "null_resource" "lambda_ecr_image" {
  triggers = {
    python_file = md5(file("${path.module}/lambdas/sonic-pyin/app.py"))
    docker_file = md5(file("${path.module}/lambdas/sonic-pyin/Dockerfile"))
  }

  provisioner "local-exec" {
    command = <<EOF
           aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com
           cd ${path.module}/lambdas/sonic-pyin
           docker build -t ${aws_ecr_repository.sonic_pyin.repository_url}:${local.ecr_image_tag} .
           docker push ${aws_ecr_repository.sonic_pyin.repository_url}:${local.ecr_image_tag}
       EOF
  }
}


data "aws_ecr_image" "lambda_image" {
  depends_on = [
    null_resource.lambda_ecr_image
  ]
  repository_name = aws_ecr_repository.sonic_pyin.name
  image_tag       = local.ecr_image_tag
}


resource "aws_lambda_function" "sonic_pyin" {
  depends_on = [
    null_resource.lambda_ecr_image
  ]
  function_name = "${var.project_name}-sonic-pyin"
  role          = aws_iam_role.lambda.arn
  timeout       = 300
  image_uri     = "${aws_ecr_repository.sonic_pyin.repository_url}@${data.aws_ecr_image.lambda_image.id}"
  package_type  = "Image"

  tags = local.tags
}


resource "aws_lambda_function" "sonic_pyin_v2" {
  depends_on = [
    null_resource.lambda_ecr_image
  ]
  function_name = "${var.project_name}-sonic-pyin-v2"
  role          = aws_iam_role.lambda.arn
  timeout       = 300
  image_uri     = "${aws_ecr_repository.sonic_pyin.repository_url}@${data.aws_ecr_image.lambda_image.id}"
  package_type  = "Image"

  environment {

    variables = {
      S3_DESTINATION_BUCKET = local.s3_destination_bucket_name
    }
  }

  tags = local.tags
}
