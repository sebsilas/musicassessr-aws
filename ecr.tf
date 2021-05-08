resource "aws_ecr_repository" "shiny_app" {
  name = "${var.project_name}_shiny_app"

  tags = local.tags
}


resource "aws_ecr_repository" "sonic_pyin" {
  name = "${var.project_name}_sonic_pyin"

  tags = local.tags
}