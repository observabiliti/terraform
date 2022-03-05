terraform {
  backend "remote" {
      organization = "krishna01"
      workspaces {
          name = "terraform-work"
      }
  }
}

provider "aws" {
    region = var.region_name
    access_key = var.AWS_ACCESS_KEY
    secret_key = var.AWS_SECRET_KEY
}

data "aws_vpc" "main" {
    id = "vpc-0cf8da123df4a7ca6"
}

data "template_file" "userdata" {
    template = file("./userdata.yml")
} 

resource "aws_instance" "vm1" {
    ami = "ami-076754bea03bde973"
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.my_pub_key.key_name}"
    vpc_security_group_ids = [aws_security_group.my_sec_grp.id]
    user_data = data.template_file.userdata.rendered
    tags = {
        Name = "my-vm1"
    } 
}

resource "aws_key_pair" "my_pub_key" {
  key_name   = "my_pub_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCdy0K/D3MfhMRfBo1bebVmEmi5Q0FJRUZAECCFz/kqsa4sVJif/19sHOjn2/XEyCEJnqwLBksEYNSz9krWioQnzicIBxqGaa+ptHKYqV6JKtPEZtx831o+kX1Xdmi+E09BuQKn3raFULlpusTq/tpSdPdkINf4VylhVBziIrgmQ45RDmIIg3pRGoqtW42E35v+uQC6raFo6S2c2GZZgRWRGFpuYDofI0iuxqYukabgdbqsz0gsJplOKro/bPokYBlz8PLmtuQTWcQ9LmVD1lg+nkjFp2VDxWeN85zLyCBZZR9KTknVtSDfo4aFlwSly3LGLiSpcFkcsL7WsHYDWfIkf6sfiCPXI1FfFNHj4d1wWa3plnH8zSJmE+jN2dff7QiP2rWH5ycFn/uBUV/+qTj6gjTO2wN3ajNyc93ivuOkgoWyXdgX7g77dG8FN58dI0jnHwQZZcHtle7jb0CkJ6s3jzzV1yuSMh1jk2rezBedBkjEpPvgcvWJyYRrkqjvGC+pMabCz6ecXPaW1Rv05NuMpjubPiVIHm5wiCTwafn5SICydGcIWCslYJWu0p5k+SbiLT5NMgiXSrfp1JaHotLbQ5iH99gEDkY3+WSRC1C6G5zFRgNsvLpahdYKd9eHIw6BiDujsQXPxDMKIaU/ZG67Q/i8t1bZUorzIs1PDA4pOw== rohith.m.n@sap.com"
}

resource "aws_security_group" "my_sec_grp" {
  name        = "my_sec_grp"
  description = "my server security group"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description      = "Open http port 80"
    from_port        = 80
    to_port          = 80
    protocol         = "http"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }

  ingress {
    description      = "SSH from local"
    from_port        = 22
    to_port          = 22
    protocol         = "ssh"
    cidr_blocks      = ["117.192.225.172/32"]
    ipv6_cidr_blocks = []
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

output "public_ip" {
    value = aws_instance.vm1.public_ip
}
