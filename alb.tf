resource "aws_lb" "front-end" {
  name               = "${var.project_name}-alb-front-end"
  subnets            = module.vpc.public_subnets
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]

  tags = local.tags
}

resource "aws_lb_listener" "https_forward" {
  load_balancer_arn = aws_lb.front-end.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = "arn:aws:iam::983365236998:server-certificate/CSC"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }
}

resource "aws_lb_target_group" "ecs" {
  name        = "${var.project_name}-front-end-target-gp"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "60"
    protocol            = "HTTP"
    matcher             = "200-299"
    timeout             = "20"
    path                = "/"
    unhealthy_threshold = "2"
  }
}