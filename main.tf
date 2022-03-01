
locals {
  name = "rohith"
}

# Create a VPC
resource "aws_vpc" "terraform_vpc" {
  cidr_block = "10.0.0.0/16"
}
