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

  vpc_zone_identifier = var.is_create_lb ? var.private_subnet_ids : var.public_subnet_ids

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

  network_interfaces = var.is_create_lb ? [] : [{
        associate_public_ip_address = true
        security_groups = local.security_group_ids
      }] 

  vpc_security_group_ids = var.is_create_lb ? local.security_group_ids : []

}
