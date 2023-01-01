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

resource "aws_instance" "ec2" {

  for_each                    = var.nodes
  ami                         = data.aws_ami.debian_linux.id
  instance_type               = each.value.instance_type
  availability_zone           = each.value.availability_zone
  subnet_id                   = each.value.subnet_id
  key_name                    = aws_key_pair.kp.key_name
  associate_public_ip_address = var.enable_public_ip
  monitoring = false
  #volume_tags = false


root_block_device {
      encrypted = true
  }

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_size = 8
    volume_type = "gp2"
    delete_on_termination = true
    encrypted = true
  }

metadata_options {
    http_tokens = "required"
  } 

  #user_data_base64 = base64encode(local.user_data)

  vpc_security_group_ids = each.value.vpc_security_group_ids

  tags = {
    Name = "${var.prefix}-ec2-${each.key}"
  }
}

resource "aws_key_pair" "kp" {
  key_name   = "${var.prefix}-kp"
  public_key = var.public_key
}

#resource "aws_eip" "eip" {
#  instance = aws_instance.ec2.eip
#  vpc      = var.enable_eip
#}

#resource "aws_eip_association" "eip_assoc" {
#  instance_id   = "i-0b07547e078c64a4e"
#  allocation_id = aws_eip.ip1.id
#}