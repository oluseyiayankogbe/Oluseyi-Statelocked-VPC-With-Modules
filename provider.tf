#0. Configure The Provider
terraform {
  backend "s3" {
    bucket         = "doktorsanti-s3statebackend062023"
    dynamodb_table = "doktorsanti-dynamodbtable"
    key            = "global/mystatefile2/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.64.0"
    }
  }
}

# Configuration options
provider "aws" {
  region = var.region
}