locals {
  subnets_ids   = tolist(data.aws_subnet_ids.current.ids)
  stage         = terraform.workspace
  account_id    = data.aws_caller_identity.current.account_id
  ecr_image_tag = "latest"

  tags = merge(var.project_tags, { STAGE = local.stage })
}


data "aws_caller_identity" "current" {}


data "aws_vpc" "default" {
  default = true
}


data "aws_subnet_ids" "current" {
  vpc_id = data.aws_vpc.default.id
}


resource "null_resource" "shiny_app_image" {
  triggers = {
    r_file      = md5(file("${path.module}/app/source_code/funs.R"))
    docker_file = md5(file("${path.module}/app/Dockerfile"))
  }

  provisioner "local-exec" {
    command = <<EOF
           aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com
           cd ${path.module}/app
           docker build -t ${aws_ecr_repository.shiny_app.repository_url}:${local.ecr_image_tag} .
           docker push ${aws_ecr_repository.shiny_app.repository_url}:${local.ecr_image_tag}
       EOF
  }
}