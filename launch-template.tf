# Launch Configuration Template
module "launch_template" {
  source      = "oozou/launch-template/aws"
  version     = "1.0.3"
  prefix      = var.prefix
  environment = var.environment
  name        = "pritunl-vpn"
  user_data = base64encode(templatefile("${path.module}/template/user_data.sh",
    {
      efs_id              = module.efs.id
      efs_access_point_id = module.efs.access_point_ids["data"]
      domain              = var.route53_zone_name
  }))
  iam_instance_profile   = { arn : aws_iam_instance_profile.this.arn }
  ami_id                 = var.ami == "" ? data.aws_ami.amazon_linux.id : var.ami
  key_name               = var.key_name
  instance_type          = var.instance_type
  vpc_security_group_ids = local.security_group_ids
  enable_monitoring      = var.enable_ec2_monitoring
  tags                   = local.tags
}
