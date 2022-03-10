terraform {
#   backend "remote" {
#       organisation = "krishna01"
#       workspaces {
#           name = "terraform-work"
#       }
#   }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.3.0"
    }
  }
}

#ap-south-1
provider "aws" {
    region = var.region_name
    alias = "mumbai"
    access_key = var.AWS_ACCESS_KEY
    secret_key = var.AWS_SECRET_KEY
}

#eu-central-1
provider "aws" {
    region = "eu-central-1"
    alias = "europe"
    access_key = var.AWS_ACCESS_KEY
    secret_key = var.AWS_SECRET_KEY
}

data "aws_ami" "mumbai-ami" {
  provider = aws.mumbai
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "aws_ami" "europe-ami" {
  provider = aws.europe
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "mumbai-vm" {
    ami = data.aws_ami.mumbai-ami.id
    provider = aws.mumbai
    instance_type = "t2.micro"
    lifecycle {
      #create_before_destroy(bool)
      #prevent_destroy(bool)
      #ignore_changes(list of attribute names)
      prevent_destroy = false
    }
    tags = {
        Name = "mumbai-server"
    }
}

resource "aws_instance" "europe-vm" {
    ami = data.aws_ami.europe-ami.id
    provider = aws.europe
    instance_type = "t2.micro"
    tags = {
        Name = "europe-server"
    }
}

output "mumbai_vm_public_ips" {
    value = aws_instance.mumbai-vm.public_ip
}
output "europe_vm_public_ips" {
    value = aws_instance.europe-vm.public_ip
}