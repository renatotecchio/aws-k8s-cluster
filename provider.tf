terraform {

  required_version = ">=1.0.0, <2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.48.0"
    }
  }

  backend "s3" {
    bucket = "terraformstate-renatotecchio"
    key    = "aws-k8s-cluster.tfstate"
    region = "eu-west-1"
    encrypt = true
    #dynamodb_table = "terraform-state-lock-dynamo"

  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = local.tags
  }
}