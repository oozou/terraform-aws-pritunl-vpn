module "ec2" {
  source                       = "oozou/ec2-instance/aws"
  version                      = "1.0.2"
  prefix                       = var.prefix
  environment                  = var.environment
  name                         = "pritunl-vpn"
  is_create_eip                = true
  is_batch_run                 = false
  ami                          = var.ami == "" ? data.aws_ami.amazon_linux.id : var.ami
  vpc_id                       = var.vpc_id
  subnet_id                    = var.subnet_id
  key_name                     = var.key_name
  additional_sg_attacment_ids  = var.additional_sg_attacment_ids
  user_data                    = file("${path.module}//template/user_data.sh")
  security_group_ingress_rules = var.security_group_ingress_rules
  instance_type                = var.instance_type
  tags                         = local.tags
}
