terraform {
  cloud {
    organization = "krishna01"
    workspaces {
      tags = ["ter-cloud"]
    }
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.3.0"
    }
  }
}

# Configuration options
provider "aws" {
  region = var.region_name
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}