locals {
  subnets_ids   = tolist(data.aws_subnet_ids.current.ids)
  stage         = terraform.workspace
  account_id    = data.aws_caller_identity.current.account_id
  ecr_image_tag = "latest"

  tags = merge(var.project_tags, { STAGE = local.stage })
}


data "aws_caller_identity" "current" {}


data "template_file" "container_definitions" {
  template = file("${path.module}/task-definitions/${var.container_definitions_file}")

  vars = {
    container_name = var.container_name
    image          = "${aws_ecr_repository.shiny_app.repository_url}:${local.ecr_image_tag}"
    container_port = var.container_port
  }
}


data "aws_vpc" "default" {
  default = true
}


data "aws_subnet_ids" "current" {
  vpc_id = data.aws_vpc.default.id
}


resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-${local.stage}_ecs_cluster"

  tags = local.tags
}


resource "null_resource" "shiny_app_image" {
  triggers = {
    r_file      = md5(file("${path.module}/app/source_code/ui.R"))
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


resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project_name}-${local.stage}_family"
  container_definitions    = data.template_file.container_definitions.rendered
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.aws_ecs_task_definition_params["cpu"]
  memory                   = var.aws_ecs_task_definition_params["memory"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  tags = local.tags

  depends_on = [
    null_resource.shiny_app_image,
  ]
}


resource "aws_ecs_service" "this" {
  name            = "${var.project_name}-${local.stage}_service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [local.subnets_ids[0]]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }
}