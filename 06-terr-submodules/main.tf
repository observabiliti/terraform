terraform {
}

module "aws_server" {
    source = ".//submodules"
    instance_type = "t2.micro"
}

output "ins_publicip" {
    value = module.aws_server.public_ip
}