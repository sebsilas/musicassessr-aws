locals {
  subnets_ids   = tolist(data.aws_subnet_ids.current.ids)
  stage         = terraform.workspace
  account_id    = data.aws_caller_identity.current.account_id
  ecr_image_tag = "latest"

  tags = merge(var.project_tags, { STAGE = local.stage })
}


data "aws_caller_identity" "current" {}


data "aws_vpc" "default" {
  default = true
}


data "aws_availability_zones" "azs" {
}


data "aws_subnet_ids" "current" {
  vpc_id = data.aws_vpc.default.id
}



module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.azs.names, 0, 1)
  private_subnets = ["10.0.0.0/24"]
  public_subnets  = ["10.0.8.0/24"]

  enable_nat_gateway = true

  tags = local.tags
}

resource "aws_instance" "shiny_app" {
  ami                    = "ami-04ca3c46d90ed5877"
  subnet_id              = module.vpc.public_subnets[0]
  instance_type          = "t3.medium"
  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [aws_security_group.ec2.id]
  user_data              = "#!/bin/bash\n sudo systemctl restart shiny-server"
  root_block_device {
    volume_size = 30
  }
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "shiny-ec2-key"
  public_key = tls_private_key.this.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.this.private_key_pem}' > ./shiny-ec2-key.pem"
  }
}