resource "aws_db_instance" "shiny-db" {
  allocated_storage    = 10
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  name                 = "melodypost"
  username             = "postgres"
  identifier           =  "melody"
  password             = var.db_password
  skip_final_snapshot  = true
  publicly_accessible =  true
  iam_database_authentication_enabled = true
  vpc_security_group_ids = [aws_security_group.rds.id]
}


