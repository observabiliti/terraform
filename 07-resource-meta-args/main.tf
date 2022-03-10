terraform {
  backend "remote" {
      organisation = "krishna01"
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
    region = var.region_name
    access_key = var.AWS_ACCESS_KEY
    secret_key = var.AWS_SECRET_KEY
}

resource "aws_iam_role" "ec2_s3_access_role" {
    name = "s3-role"
    assume_role_policy = "${file("assume_role_policy.json")}"  
}

resource "aws_iam_policy" "s3-policy" {
    name = "s3-policy"
    policy = "${file("policys3bucket.json")}"
}

resource "aws_iam_policy_attachment" "attach-policy" {
    name =  "attach-policy"
    roles = ["${aws_iam_role.ec2_s3_access_role.name}"]
    policy_arn = "${aws_iam_policy.s3-policy.arn}"
}

resource "aws_iam_instance_profile" "aws-instance-profile" {
    name = "aws-instance-profile"
    role = "${aws_iam_role.ec2_s3_access_role.name}"
}

# resource meta argument - count is used here
resource "aws_instance" "my-vms" {
    ami = "ami-076754bea03bde973"
    instance_type = "t2.micro"
    iam_instance_profile = "${aws_iam_instance_profile.aws-instance-profile.name}"
    count = 2
    tags = {
        Name = "server - ${count.index}"
    }
    depends_on = [
        aws_iam_instance_profile.aws-instance-profile,
    ]
}

###Note: count and for_each are mutually exxlusive
# resource meta argument - for_each is used here
resource "aws_instance" "my-new-vms" {
    ami = "ami-076754bea03bde973"
    for_each = {
        nano = "t2.nano"
        micro = "t2.micro"
    }
    instance_type = each.value
    tags = {
        Name = "server - ${each.key}"
    }
}


output "instance_public_ips" {
    value = "${join(",",aws_instance.my-vms[*].public_ip)}"
}

###Note: for map data structure, we need to use balues built-in function as shown below
output "new_instance_public_ips" {
    value = values(aws_instance.my-new-vms)[*].public_ip
}