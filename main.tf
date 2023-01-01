locals {
  tags = {
    project     = var.project_name
    environment = var.environment
    owner       = var.owner
    terraform   = "true"
  }
}

locals {
  prefix = "${local.tags["environment"]}-${local.tags["project"]}-${var.region}"
}

locals {
  azs = ["${var.region}a", "${var.region}b", "${var.region}c"]
}

module "network" {
  source        = "./modules/network"
  cidr_vpc      = var.cidr_vpc
  azs           = local.azs
  cidr_public   = var.cidr_public
  cidr_private  = var.cidr_private
  cidr_database = var.cidr_database
  prefix        = local.prefix

  enable_ipv6 = false
  #enable_nat_gateway = false
  #enable_vpn_gateway = false
  #
  #enable_dns_hostnames = true
  #enable_dns_support   = true
}

locals {
  nodes = {
    master-1 = {
      instance_type          = var.instance_type
      availability_zone      = element(local.azs, 0)
      subnet_id              = element(module.network.public_subnets, 0)
      vpc_security_group_ids = [module.sg.security_group_id_ssh, module.sg.security_group_id_http]
    }
    #worker-1 = {
    #  instance_type     = var.instance_type
    #  availability_zone = element(local.azs, 1)
    #  subnet_id         = element(module.network.public_subnets, 1)
    #vpc_security_group_ids = [module.sg.security_group_id_ssh]
    #}
    #worker-2 = {
    #  instance_type     = var.instance_type
    #  availability_zone = element(local.azs, 2)
    #  subnet_id         = element(module.network.public_subnets, 2)
    #vpc_security_group_ids = [module.sg.security_group_id_ssh]
    #}
  }
}

module "cluster" {
  source           = "./modules/cluster"
  nodes            = local.nodes
  prefix           = local.prefix
  public_key       = var.public_key
  enable_public_ip = true
}

locals {
  sg_rules = {
    ssh = {
      sg_name        = "allow_ssh"
      sg_description = "Allow SSH inbound traffic"
      sg_from_port   = "22"
      sg_to_port     = "22"
      sg_protocol    = "tcp"
      sg_cidr_blocks = "0.0.0.0/0"
    }
    http = {
      sg_name        = "allow_http"
      sg_description = "Allow HTTP inbound traffic"
      sg_from_port   = "80"
      sg_to_port     = "80"
      sg_protocol    = "tcp"
      sg_cidr_blocks = "0.0.0.0/0"
    }
    https = {
      sg_name        = "allow_https"
      sg_description = "Allow HTTPS inbound traffic"
      sg_from_port   = "443"
      sg_to_port     = "443"
      sg_protocol    = "tcp"
      sg_cidr_blocks = "0.0.0.0/0"
    }
  }
}

module "sg" {
  source    = "./modules/sg"
  prefix    = local.prefix
  sg_rules  = local.sg_rules
  sg_vpc_id = module.network.vpc_id
}