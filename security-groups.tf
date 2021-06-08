resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-${local.stage}-ecs-sg"
  description = "Task Allowed Ports"
  vpc_id  = module.vpc.vpc_id
  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_security_group" "alb" {
  name        = "lb-sg"
  description = "controls access to the Application Load Balancer (ALB)"
  vpc_id  = module.vpc.vpc_id
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}


resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-${local.stage}-ecs-sg-2"
  description = "Container Instance Allowed Ports"
  vpc_id  = module.vpc.vpc_id
  
  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}