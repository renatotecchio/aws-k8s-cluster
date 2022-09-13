data "aws_ami" "debian_linux" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["debian-11-amd64-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  #filter {
  #  name = "Platform"
  #  values = ["Debian"]
  #}
}

variable "key_name" {}
variable "public_key" {}

module "key_pair" {
  source     = "terraform-aws-modules/key-pair/aws"
  key_name   = var.key_name
  public_key = var.public_key
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.project_name}-icmp"
  description = "EC2 instance - ICMP"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["all-icmp"]
  egress_rules        = ["all-all"]

  tags = local.tags
}

module "ssh_service_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.project_name}-ssh"
  description = "EC2 instance - SSH"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
}

module "web_service_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.project_name}-web"
  description = "EC2 instance - WEB"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  #ingress_with_cidr_blocks = [
  #  {
  #    from_port   = 8080
  #    to_port     = 8090
  #    protocol    = "tcp"
  #    description = "User-service ports"
  #    cidr_blocks = "10.10.0.0/16"
  #  },
  #  {
  #    rule        = "postgresql-tcp"
  #    cidr_blocks = "0.0.0.0/0"
  #  },
  #]
}

variable "instance_type" {}

#module "ec2_instance" {
#  source  = "terraform-aws-modules/ec2-instance/aws"
#  version = "~> 4.0"

#  for_each = toset(["master-1","node-1","node-2"])
  
#  name = "${local.project_name}-${each.key}"
#  ami           = data.aws_ami.debian_linux.id
#  instance_type = var.instance_type
#  key_name      = var.key_name
#  vpc_security_group_ids = [module.security_group.security_group_id, module.web_service_sg.security_group_id]
#  subnet_id              = element(module.vpc.public_subnets, 0)
  #monitoring             = true
  #user_data_base64 = base64encode(local.user_data)

#  tags = local.tags

#}

locals {
  multiple_instances = {
    master-1 = {
      instance_type     = var.instance_type
      availability_zone = element(module.vpc.azs, 0)
      subnet_id         = element(module.vpc.public_subnets, 0) 
    }
    node-1 = {
      instance_type     = var.instance_type
      availability_zone = element(module.vpc.azs, 1)
      subnet_id         = element(module.vpc.public_subnets, 1)
    }
    node-2 = {
      instance_type     = var.instance_type
      availability_zone = element(module.vpc.azs, 2)
      subnet_id         = element(module.vpc.public_subnets, 2)
    }
  }
}

module "ec2_multiple" {
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.0"

  for_each = local.multiple_instances

  name = "${local.project_name}-multi-${each.key}"

  ami                    = data.aws_ami.debian_linux.id
  instance_type          = each.value.instance_type
  key_name      = var.key_name
  availability_zone      = each.value.availability_zone
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = [module.security_group.security_group_id]

  enable_volume_tags = false
  #root_block_device  = lookup(each.value, "root_block_device", [])
  #monitoring             = true
  #user_data_base64 = base64encode(local.user_data)

  tags = local.tags
}

#resource "aws_eip" "ip1" {
#    vpc = true
#}

#resource "aws_eip_association" "eip_assoc" {
#  instance_id   = "i-0b07547e078c64a4e"
#  allocation_id = aws_eip.ip1.id
#}