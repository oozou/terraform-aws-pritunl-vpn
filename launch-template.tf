# Launch Configuration Template
module "launch_template" {
  source      = "git::ssh://git@github.com/oozou/terraform-aws-launch-template.git?ref=v1.0.2"
  prefix      = var.prefix
  environment = var.environment
  name        = "pritunl-vpn"
  user_data = base64encode(templatefile("${path.module}/template/user_data.sh",
    {
      efs_dns_name = module.efs.dns_name
  }))
  iam_instance_profile   = { arn : aws_iam_instance_profile.this.arn }
  ami_id                 = var.ami == "" ? data.aws_ami.amazon_linux.id : var.ami
  key_name               = var.key_name
  instance_type          = var.instance_type
  vpc_security_group_ids = local.security_group_ids
  tags                   = local.tags
}
