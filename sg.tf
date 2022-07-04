# Security Group
resource "aws_security_group" "this" {
  count = var.is_create_security_group ? 1 : 0

  name_prefix = format("%s-ec2-sg", local.name)
  vpc_id      = var.vpc_id
  description = "Pritunl VPN egress rule for outbound"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    local.tags,
    { "Name" = format("%s-ec2-sg", local.name) },
  )
}

resource "aws_security_group_rule" "ingress" {
  for_each = var.is_create_security_group ? var.security_group_ingress_rules : null

  type              = "ingress"
  from_port         = lookup(each.value, "from_port", lookup(each.value, "port", null))
  to_port           = lookup(each.value, "to_port", lookup(each.value, "port", null))
  protocol          = lookup(each.value, "protocol", "tcp")
  security_group_id = aws_security_group.this[0].id

  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  description              = lookup(each.value, "description", null)
  ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null)
  prefix_list_ids          = lookup(each.value, "prefix_list_ids", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
}
