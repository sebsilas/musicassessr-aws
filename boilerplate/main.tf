locals {
  stage         = terraform.workspace
  account_id    = data.aws_caller_identity.current.account_id
  ecr_image_tag = "v2"

  tags = merge(var.project_tags, { STAGE = local.stage })
}


data "aws_caller_identity" "current" {}