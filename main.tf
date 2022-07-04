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
  vpc_security_group_ids = concat(var.additional_sg_attacment_ids, var.is_create_security_group ? [aws_security_group.this[0].id] : [])
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
  tags = { workspace = "test-workspace" }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "this" {
  name_prefix = local.name
  # availability_zones = var.availability_zones
  vpc_zone_identifier = var.subnet_ids
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  # launch_configuration = aws_launch_configuration.this.name
  launch_template {
    id      = module.launch_template.id
    version = "$Latest"
  }

  # load_balancers = [aws_lb.this.id]
  target_group_arns = [aws_lb_target_group.public.arn, aws_lb_target_group.private.arn]
  dynamic "tag" {
    for_each = merge(local.tags, { Name = local.name })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
