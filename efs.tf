# EFS
module "efs" {
  source = "git::ssh://git@github.com/oozou/terraform-aws-efs.git?ref=v1.0.0"

  prefix      = var.prefix
  environment = var.environment
  name        = "pritunl-data"

  vpc_id  = var.vpc_id
  subnets = var.subnet_ids
}
