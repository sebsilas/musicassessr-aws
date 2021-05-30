locals {
  user_data = <<EOF
#!/bin/bash
sudo apt-get update && \
sudo apt-get upgrade -y && \
sudo apt-get clean
sudo apt-get install r-base
sudo apt-get install gdebi-core
wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.4.1106-amd64.deb
sudo gdebi rstudio-server-1.4.1106-amd64.deb

sudo su - \
-c "R -e \"install.packages('shiny', repos='https://cran.rstudio.com/')\""

sudo su - \
-c "R -e \"install.packages('rmarkdown', repos='https://cran.rstudio.com/')\""

sudo su - \
-c "R -e \"install.packages('ggplot2', repos='https://cran.rstudio.com/')\""
EOF
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "shiny_app" {
  ami              = data.aws_ami.ubuntu.id
  instance_type    = "t3.small"
  key_name         = aws_key_pair.deployer.key_name
  security_groups  = aws_security_group.ec2_shiny.id
  user_data_base64 = base64encode(local.user_data)

  root_block_device {
    volume_size = 30
  }

  tags = local.tags
}

resource "aws_key_pair" "deployer" {
  key_name    = "${var.project_name}-key"
  public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}