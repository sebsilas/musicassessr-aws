data "aws_vpc" "default" {
  default = true
}


resource "aws_db_instance" "shiny-db" {
  allocated_storage                   = 10
  engine                              = "postgres"
  instance_class                      = "db.t3.micro"
  name                                = var.db_name
  username                            = var.username
  identifier                          = "melody"
  password                            = var.db_password
  skip_final_snapshot                 = true
  publicly_accessible                 = true
  iam_database_authentication_enabled = true
  vpc_security_group_ids              = [aws_security_group.rds.id]
}


resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Allow the EC2 instance to connect to RDS"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    #security_group = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}