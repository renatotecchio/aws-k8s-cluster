terraform {
  
  required_version = ">=1.0.0, <2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.29.0"
    }
  }

  backend "s3" {
    region = "eu-west-1"
    bucket = "terraformstate-renatotecchio"
    key    = "aws-k8s-cluster"
  }

}

provider "aws" {
  region = var.region
  default_tags {
    tags = local.tags
  }
}

locals {
  project_name = "k8s-cluster"
  tags = {
    Project     = local.project_name
    Owner       = "renatotecchio"
    Environment = "dev"
    Terraform   = "true"
  }
}
