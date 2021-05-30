resource "aws_security_group" "ec2_shiny" {
  name        = "ec2_shiny"
  description = "controls access to the EC2 instance"

  tags = local.tags
}


resource "aws_security_group_rule" "ec2_https_rule" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.ec2_shiny.id
}


resource "aws_security_group_rule" "ec2_http_rule" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 3838
  to_port     = 3838
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.ec2_shiny.id
}


resource "aws_security_group_rule" "ec2_egress_rule" {
  type        = "egress"
  protocol    = "-1"
  from_port   = 0
  to_port     = 0
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.ec2_shiny.id
}