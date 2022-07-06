# EFS
module "efs" {
  source = "git::ssh://git@github.com/oozou/terraform-aws-efs.git?ref=feat/support-ip-mount"

  prefix      = var.prefix
  environment = var.environment
  name        = "pritunl-data"
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
  subnets = var.subnet_ids
}
