module "vpn" {
  source = "../../"

  prefix      = var.prefix
  environment = var.environment

  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  instance_type           = "t3a.small"
  route53_zone_name       = "aws.waruwat.com"
  public_lb_vpn_domain    = "vpn"
  private_lb_vpn_domain   = "vpn-console"
  is_enabled_https_public = true

  security_group_ingress_rules = {
    allow_to_connect_vpn = {
      port        = "12383"
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = var.tags
}
