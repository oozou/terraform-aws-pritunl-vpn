module "vpn" {
  source                    = "../../"
  prefix                    = var.prefix
  environment               = var.environment
  vpc_id                    = module.vpc.vpc_id
  public_subnet_ids         = module.vpc.public_subnet_ids
  private_subnet_ids        = module.vpc.private_subnet_ids
  instance_type             = "t3a.small"
  is_create_route53_reccord = false
  is_create_private_lb      = true
  is_enabled_https_public   = true
  tags                      = var.tags
}
