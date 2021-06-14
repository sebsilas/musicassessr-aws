variable "project_tags" {
  description = "Project tags to be attached to resources"
  type = object({
    PROJECT_NAME = string
    OWNER        = string
    COSTCENTER   = string
  })
}


variable "aws_ecs_task_definition_params" {
  description = "Task definition parameters"
  type        = map(string)
}


variable "container_name" {
  type = string
}


variable "container_port" {
  type = number
}


variable "container_definitions_file" {
  type    = string
  default = "task.json.tpl"
}


variable "project_name" {
  type = string
}


variable "region" {
  type    = string
  default = "eu-central-1"
}