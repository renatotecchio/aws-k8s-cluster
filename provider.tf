terraform {
  required_version = ">=1.0.0, <2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.29.0"
    }
  }
}

variable "region" {}

locals {
  project_name = "k8s-cluster"
  tags = {
    Project     = local.project_name
    Owner       = "renatotecchio"
    Environment = "dev"
    Terraform   = "true"
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = local.tags
  }
}

terraform {
  backend "s3" {
    region = "eu-west-1"                    # TODO substitua pela região onde você criou o bucket
    bucket = "terraformstate-renatotecchio" # TODO substitua pelo nome que você deu ao bucket
    key    = "aws-k8s-cluster"
  }
}