# module "ec2" {
#   source                       = "git::ssh://git@github.com/oozou/terraform-aws-ec2-instance.git?ref=v1.0.2"
#   prefix                       = var.prefix
#   environment                  = var.environment
#   name                         = "pritunl-vpn"
#   is_create_eip                = true
#   is_batch_run                 = false
#   ami                          = var.ami == "" ? data.aws_ami.amazon_linux.id : var.ami
#   vpc_id                       = var.vpc_id
#   subnet_id                    = var.subnet_id
#   key_name                     = var.key_name
#   additional_sg_attacment_ids  = var.additional_sg_attacment_ids
#   user_data                    = file("${path.module}//template/user_data.sh")
#   security_group_ingress_rules = var.security_group_ingress_rules
#   instance_type                = var.instance_type
#   tags                         = local.tags
# }






# Launch Configuration Template
module "launch_template" {
  source      = "git::ssh://git@github.com/oozou/terraform-aws-launch-template.git?ref=v1.0.2"
  prefix      = var.prefix
  environment = var.environment
  name        = "pritunl-vpn"
  user_data   = base64encode(file("${path.module}/template/user_data.sh"))
  # block_device_mappings = [{
  #   device_name = "/dev/sda1"
  #   ebs = {
  #     volume_size = 20
  #     volume_type = "gp3"
  #   }
  # }]
  iam_instance_profile   = { arn : aws_iam_instance_profile.this.arn }
  ami_id                 = var.ami == "" ? data.aws_ami.amazon_linux.id : var.ami
  key_name               = var.key_name
  instance_type          = var.instance_type
  vpc_security_group_ids = local.security_group_ids
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
  tags = { workspace = "test-workspace" }
}
