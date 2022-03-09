terraform {
  backend "remote" {
      organization = "krishna01"
      workspaces {
          name = "terraform-work"
      }
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.3.0"
    }
  }
}

provider "aws" {
    access_key = var.AWS_ACCESS_KEY
    secret_key = var.AWS_SECRET_KEY
    region = var.region_name
}

resource "aws_instance" "vm1" {
    ami = "ami-076754bea03bde973"
    instance_type = var.instance_type
    tags = {
        Name = "vm1"
    }
}
variable "instance_type" {
    type = string
    description = "Size of the instance"
    sensitive = true # in plan/apply output it will not show, but in state file it is clearly visible.
    validation {
        condition = can(regex("^t2.",var.instance_type))
        error_message = "The instance must be t2 type instance."
    }

}
output "ins_publicip" {
    value = aws_instance.vm1.public_ip
}