data "aws_ami" "ecs_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
  owners = ["amazon"]
}


resource "aws_instance" "shiny_app" {
  ami                    = data.aws_ami.ecs_ami.id
  iam_instance_profile   = aws_iam_instance_profile.ecs_agent.name
  subnet_id=module.vpc.public_subnets[0]
  instance_type          = "t3.small"
  key_name               = "shiny"
  vpc_security_group_ids = [aws_security_group.ec2.id]
  user_data              = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.this.name} >> etc/ecs/ecs.config"
  root_block_device {
    volume_size = 30
  }
}


data "template_file" "container_definitions" {
  template = file("${path.module}/task-definitions/${var.container_definitions_file}")

  vars = {
    container_name  = var.container_name
    image           = "${aws_ecr_repository.shiny_app.repository_url}:${local.ecr_image_tag}"
    container_port  = var.container_port
    cloudwatch_logs = aws_cloudwatch_log_group.ecs-log.name
  }
}


resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-${local.stage}_ecs_cluster"

  tags = local.tags
}


resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project_name}-${local.stage}_family"
  container_definitions    = data.template_file.container_definitions.rendered
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  cpu                      = var.aws_ecs_task_definition_params["cpu"]
  memory                   = var.aws_ecs_task_definition_params["memory"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn


  depends_on = [
    null_resource.shiny_app_image,
  ]

  tags = local.tags

}


resource "aws_ecs_service" "this" {
  name            = "${var.project_name}-${local.stage}_service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.ecs.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  depends_on = [
    null_resource.shiny_app_image, aws_lb_listener.https_forward,
  ]

  tags = local.tags
}


resource "aws_cloudwatch_log_group" "ecs-log" {
  name = "awslogs-ecs-logs"


  tags = local.tags
}