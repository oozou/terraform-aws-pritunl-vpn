# EFS
module "efs" {
  source = "git::ssh://git@github.com/oozou/terraform-aws-efs.git?ref=v1.0.3"

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
}
