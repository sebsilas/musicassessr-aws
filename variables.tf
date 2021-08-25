variable "project_tags" {
  description = "Project tags to be attached to resources"
  type = object({
    PROJECT_NAME = string
    OWNER        = string
    COSTCENTER   = string
  })
}


variable "project_name" {
  type = string
}


variable "region" {
  type    = string
  default = "eu-central-1"
}


variable "db_password" {
    type = string
    description = "Password for the master DB user"
}