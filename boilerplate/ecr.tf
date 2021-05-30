resource "aws_ecr_repository" "sonic_pyin" {
  name = "${var.project_name}_sonic_pyin"

  tags = local.tags
}