# module "ec2" {
#   source                       = "git::ssh://git@github.com/oozou/terraform-aws-ec2-instance.git?ref=v1.0.2"
#   prefix                       = var.prefix
#   environment                  = var.environment
#   name                         = "pritunl-vpn"
#   is_create_eip                = true
#   is_batch_run                 = false
#   ami                          = var.ami == "" ? data.aws_ami.amazon_linux.id : var.ami
#   vpc_id                       = var.vpc_id
#   subnet_id                    = var.subnet_id
#   key_name                     = var.key_name
#   additional_sg_attacment_ids  = var.additional_sg_attacment_ids
#   user_data                    = file("${path.module}//template/user_data.sh")
#   security_group_ingress_rules = var.security_group_ingress_rules
#   instance_type                = var.instance_type
#   tags                         = local.tags
# }

# # LoadBalancer
# resource "aws_lb" "this" {
#   name               = format("%s-lb", local.name)
#   internal           = false
#   load_balancer_type = "network"
#   subnets            = var.subnet_ids
#
#   tags = merge(
#     { Name = format("%s-lb", local.name) },
#     local.tags
#   )
# }


# EFS
module "efs" {
  source = "git::ssh://git@github.com/oozou/terraform-aws-efs.git?ref=v1.0.0"

  prefix      = var.prefix
  environment = var.environment
  name        = "pritunl-data"

  vpc_id  = var.vpc_id
  subnets = var.subnet_ids
}

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

# Launch Configuration Template
resource "aws_launch_configuration" "this" {
  name_prefix   = local.name
  image_id      = var.ami == "" ? data.aws_ami.amazon_linux.id : var.ami
  instance_type = var.instance_type

  key_name = var.key_name

  # If we change instance to lauch with ebs optimized,
  # it will failed to setup autoscaling group
  ebs_optimized = false

  security_groups = var.is_create_security_group ? [aws_security_group.this[0].id] : []

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_type           = var.disk_type
    volume_size           = var.disk_size
    iops                  = 0
    throughput            = 0
  }

  # ebs_block_device {
  #   device_name = "/dev/sdb"
  #   encrypted   = true
  #   volume_type = var.disk_type
  #   volume_size = var.disk_size
  # }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "this" {
  name_prefix = local.name
  # availability_zones = var.availability_zones
  vpc_zone_identifier = var.subnet_ids
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  launch_configuration = aws_launch_configuration.this.name

  # load_balancers = [aws_lb.this.id]

  dynamic "tag" {
    for_each = merge(local.tags, { Name = local.name })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_autoscaling_attachment" "this" {
#   autoscaling_group_name = aws_autoscaling_group.this.name
#   elb                    = aws_lb.this.id
# }
