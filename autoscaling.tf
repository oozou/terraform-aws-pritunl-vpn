# Auto Scaling Group
resource "aws_autoscaling_group" "this" {
  name_prefix         = local.name
  vpc_zone_identifier = local.vpc_zone_identifier
  desired_capacity    = 1
  max_size            = 1 #fix 1 to avoid race condition (if not move to document db for multi read/write)
  min_size            = 1

  launch_template {
    id      = module.launch_template.id
    version = "$Latest"
  }

  target_group_arns = concat(aws_lb_target_group.public.*.arn, aws_lb_target_group.private.*.arn)
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


resource "aws_autoscaling_policy" "this" {
  name                   = "pritunl-vpn-auto-scaling-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}
