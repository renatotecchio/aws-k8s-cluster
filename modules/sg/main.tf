resource "aws_security_group" "sg" {

  for_each    = var.sg_rules
  name        = each.value.sg_name
  description = each.value.sg_description
  vpc_id      = var.sg_vpc_id

  ingress {
    description = "${each.key} from source"
    from_port   = each.value.sg_from_port
    to_port     = each.value.sg_to_port
    protocol    = each.value.sg_protocol
    cidr_blocks = [each.value.sg_cidr_blocks]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.prefix}-sg-${each.value.sg_name}"
  }
}