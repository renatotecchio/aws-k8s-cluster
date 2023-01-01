locals {
  prefix = "${var.enviroment}-${var.region}"
}

module "networking" {
  source           = "./modules/network"
 
  name = local.project_name
  cidr = "10.0.0.0/16"

  azs              = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

  enable_ipv6 = false

  enable_nat_gateway = false
  enable_vpn_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    #Name = "${local.vpc_name}-public"
  }

  tags = local.tags

  vpc_tags = {
    Name = "vpc-${local.project_name}"
  }

}



module "k8s" {
  source           = "./modules/k8s"

}