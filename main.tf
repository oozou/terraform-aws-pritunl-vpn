# #############################################################################
# Additional Data
# #############################################################################
locals {
  tags = merge(
    {
      "Environment" = var.environment,
      "Terraform"   = "true"
    },
    var.tags
  )
  name                = format("%s-%s-%s", var.prefix, var.environment, "vpn")
  profile_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientReadWriteAccess"]
  security_group_ids  = concat([module.efs.security_group_client_id], var.additional_sg_attacment_ids, var.is_create_security_group ? [aws_security_group.this[0].id] : [])

  console_rule = [{
    port                  = 443,
    protocol              = "TCP"
    health_check_protocol = "TCP"
  }]
  public_rule              = concat(var.public_rule, var.is_enabled_https_public ? local.console_rule : [])
  private_rule             = concat(var.private_rule, local.console_rule)
  default_https_allow_cidr = var.is_enabled_https_public ? ["0.0.0.0/0"] : [data.aws_vpc.this.cidr_block]
  security_group_ingress_rules = merge({
    allow_to_config_vpn = {
      port        = "443"
      cidr_blocks = var.custom_https_allow_cidr != null ? var.custom_https_allow_cidr : local.default_https_allow_cidr
    }
    },
  var.security_group_ingress_rules)
}

resource "random_string" "host_id" {
  count = length(var.host_id) > 0 ? 0 : 1

  numeric = true
  lower   = true
  upper   = false
  length  = 32
  special = false
}

data "aws_vpc" "this" {
  id = var.vpc_id
}

# #############################################################################
# AMI
# #############################################################################
data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["137112412989"] # amazon
}

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
# IAM Roles
# #############################################################################
data "aws_iam_policy_document" "this" {
  statement {
    sid       = "IamPassRole"
    actions   = ["iam:PassRole"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ec2.amazonaws.com"]
    }
  }
  statement {
    sid = "ListEc2AndListInstanceProfiles"
    actions = [
      "iam:ListInstanceProfiles",
      "ec2:Describe*",
      "ec2:Search*",
      "ec2:Get*"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "this_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = format("%s-role", local.name)
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.this_assume_role.json
}

resource "aws_iam_role_policy" "this" {
  name = format("%s-policy", local.name)
  role = aws_iam_role.this.id

  policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = length(local.profile_policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = local.profile_policy_arns[count.index]
}

resource "aws_iam_instance_profile" "this" {
  name = format("%s-profile", local.name)
  role = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
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
      efs_id = module.efs.id,
      cloudwatch_agent_config_file = templatefile("${path.module}/templates/cloudwatch-agent-conf.json", {
        cloudwatch_metric_namespace = "EC2/pritunl-vpn"
      }),
      mongodb_drop_in_service_file = file("${path.module}/templates/systemd-mongod-drop-in.conf"),
      pritunl_host_id              = length(var.host_id) > 0 ? var.host_id : random_string.host_id[0].result
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
