module "vpn" {
  source = "../../"

  prefix      = var.prefix
  environment = var.environment

  vpc_id             = "vpc-xxxx"
  public_subnet_ids  = ["subnet-xxxx", "subnet-xxxx"]
  private_subnet_ids = ["subnet-xxxx", "subnet-xxxx"]

  instance_type           = "t3a.small"
  route53_zone_name       = "aws.xxx.com"
  public_lb_vpn_domain    = "vpn"
  private_lb_vpn_domain   = "vpn-console"
  is_enabled_https_public = true

  is_create_lb = false
  is_create_private_lb = false


  security_group_ingress_rules = {
    allow_to_connect_vpn = {
      port        = "12383"
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = var.tags
}
