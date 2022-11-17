# #############################################################################
# EFS Storage
# #############################################################################
module "efs" {
  source  = "oozou/efs/aws"
  version = "1.0.4"

  prefix                    = var.prefix
  environment               = var.environment
  name                      = "pritunl-data"
  encrypted                 = true
  enabled_backup            = var.enabled_backup
  efs_backup_policy_enabled = var.efs_backup_policy_enabled
  access_points = {
    "data" = {
      posix_user = {
        gid            = "1001"
        uid            = "5000"
        secondary_gids = "1002,1003"
      }
      creation_info = {
        gid         = "1001"
        uid         = "5000"
        permissions = "0755"
      }
    }
  }
  vpc_id  = var.vpc_id
  subnets = var.private_subnet_ids

  additional_efs_resource_policies = []

  tags = var.tags
}

# #############################################################################
# Security Groups
# #############################################################################
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
  for_each = var.is_create_security_group ? local.security_group_ingress_rules : null

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

# #############################################################################
# Laucn Template
# #############################################################################
module "launch_template" {
  source      = "oozou/launch-template/aws"
  version     = "1.0.3"
  prefix      = var.prefix
  environment = var.environment
  name        = "pritunl-vpn"
  user_data = base64encode(templatefile("${path.module}/templates/user_data.sh",
    {
      efs_id = module.efs.id
  }))
  iam_instance_profile   = { arn : aws_iam_instance_profile.this.arn }
  ami_id                 = var.ami == "" ? data.aws_ami.amazon_linux.id : var.ami
  key_name               = var.key_name
  instance_type          = var.instance_type
  vpc_security_group_ids = local.security_group_ids
  enable_monitoring      = var.enable_ec2_monitoring
  tags                   = local.tags
}

# #############################################################################
# AutoScaling Group
# #############################################################################
resource "aws_autoscaling_group" "this" {
  name_prefix         = local.name
  vpc_zone_identifier = var.private_subnet_ids
  desired_capacity    = 1
  max_size            = 1 #fix 1 to avoid race condition (if not move to document db for multi read/write)
  min_size            = 1

  launch_template {
    id      = module.launch_template.id
    version = "$Latest"
  }

  target_group_arns = concat(aws_lb_target_group.public[*].arn, aws_lb_target_group.private[*].arn)
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

resource "aws_autoscaling_policy" "this" {
  name                   = "pritunl-vpn-auto-scaling-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}

# #############################################################################
# Load Balancer
# #############################################################################


# #############################################################################
# DNS Records
# #############################################################################
data "aws_route53_zone" "this" {
  count = var.is_create_route53_reccord ? 1 : 0
  name  = var.route53_zone_name
}

resource "aws_route53_record" "public" {
  count   = var.is_create_route53_reccord ? 1 : 0
  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = format("%s.%s", var.public_lb_vpn_domain, var.route53_zone_name)
  type    = "A"
  alias {
    name                   = aws_lb.public.dns_name
    zone_id                = aws_lb.public.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "private" {
  count   = var.is_create_private_lb && var.is_create_route53_reccord ? 1 : 0
  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = format("%s.%s", var.private_lb_vpn_domain, var.route53_zone_name)
  type    = "A"
  alias {
    name                   = aws_lb.private[0].dns_name
    zone_id                = aws_lb.private[0].zone_id
    evaluate_target_health = true
  }
}
