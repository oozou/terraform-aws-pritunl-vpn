
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
