container_name                 = "shinny-app"
aws_ecs_task_definition_params = { cpu = "256", memory = "512" }
subnets                        = ["subnet-3a779765"]
container_port                 = 3838
project_name                   = "shinny-app"

project_tags = {
  PROJECT_NAME = "shinny-app"
  OWNER        = "Seb"
  COSTCENTER   = "shinny-app"
}