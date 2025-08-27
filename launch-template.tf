# Launch Configuration Template
module "launch_template" {
  source      = "oozou/launch-template/aws"
  version     = "1.0.4"
  prefix      = var.prefix
  environment = var.environment
  name        = "pritunl-vpn"
  user_data = base64encode(templatefile("${path.module}/template/user_data.sh",
    {
      efs_id = module.efs.id
  }))
  iam_instance_profile   = { arn : aws_iam_instance_profile.this.arn }
  ami_id                 = var.ami == "" ? data.aws_ami.amazon_linux.id : var.ami
  key_name               = var.key_name
  instance_type          = var.instance_type
  vpc_security_group_ids = local.vpc_security_group_ids
  enable_monitoring      = var.enable_ec2_monitoring
  network_interfaces     = local.network_interfaces
  tags                   = local.tags
}
