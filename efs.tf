# EFS
module "efs" {
  source  = "oozou/efs/aws"
  version = "1.0.4"

  prefix                    = var.prefix
  environment               = var.environment
  name                      = "pritunl-data"
  encrypted                 = true
  enabled_backup            = var.enabled_backup
  efs_backup_policy_enabled = var.efs_backup_policy_enabled
  access_points             = var.access_points
  vpc_id                    = var.vpc_id
  subnets                   = var.private_subnet_ids

  additional_efs_resource_policies = []
}
