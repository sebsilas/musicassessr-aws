resource "aws_ecr_repository" "shiny_app" {
  name = "${var.project_name}_shiny_app"

  tags = local.tags
}