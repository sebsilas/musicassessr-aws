container_name                 = "shinny_app"
aws_ecs_task_definition_params = { cpu = "256", memory = "512" }
subnets                        = ["subnet-ef2342b5"]
container_port                 = 3838
project_name                   = "shinny_app"

project_tags = {
  PROJECT_NAME = "shinny_app"
  OWNER        = "Seb"
  COSTCENTER   = "shinny_app"
}