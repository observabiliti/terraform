terraform {
    # backend "remote" {
    #     organization = "krishna01"
    #     workspaces {
    #       name = "terraform-work"
    #     }
    # }
}

provider "aws" {
    region = var.region_name
    access_key = var.AWS_ACCESS_KEY
    secret_key = var.AWS_SECRET_KEY  
}

resource "aws_instance" "my-vm2" {
    ami = "ami-076754bea03bde973"
    instance_type = "t2.micro"
    count = 2
    tags = {
        Name = "my_server-${count.index + 1}"
    }
}


resource "null_resource" "status" {
    provisioner "local-exec" {
        command = <<-EOT
        curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
        unzip awscli-bundle.zip
        ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
        aws --version
        aws ec2 wait instance-status-ok --instance-ids ${join(",",aws_instance.my-vm2.*.id)}
        EOT     
    }
    depends_on = [
      aws_instance.my-vm2
    ]
  
}
output "public_ip" {
    value = aws_instance.my-vm2.*.public_ip
    #value = "${join(",",aws_instance.my-vm2.*.public_ip)}"
}