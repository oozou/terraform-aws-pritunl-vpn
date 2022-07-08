# LoadBalancer Public
resource "aws_lb" "public" {
  name               = format("%s-public-lb", local.name)
  internal           = false
  load_balancer_type = "network"
  subnets            = var.public_subnet_ids

  tags = merge(
    { Name = format("%s-lb", local.name) },
    local.tags
  )
}

resource "aws_lb_target_group" "public" {
  count    = length(local.public_rule)
  name     = format("%s-public-%s", local.name, count.index)
  port     = local.public_rule[count.index].port
  protocol = local.public_rule[count.index].protocol
  vpc_id   = var.vpc_id

  dynamic "health_check" {
    for_each = lookup(local.public_rule[count.index], "public_health_check_port", null) == null ? [] : [1]
    content {
      port = local.public_rule[count.index].public_health_check_port
    }
  }
}

resource "aws_lb_listener" "public" {
  count             = length(local.public_rule)
  load_balancer_arn = aws_lb.public.arn
  port              = local.public_rule[count.index].port
  protocol          = local.public_rule[count.index].protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public[count.index].arn
  }
}


# LoadBalancer Private
resource "aws_lb" "private" {
  name               = format("%s-private-lb", local.name)
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids

  tags = merge(
    { Name = format("%s-lb", local.name) },
    local.tags
  )
}

resource "aws_lb_target_group" "private" {
  count              = length(local.private_rule)
  name               = format("%s-private-%s", local.name, count.index)
  preserve_client_ip = false
  port               = local.private_rule[count.index].port
  protocol           = local.private_rule[count.index].protocol
  vpc_id             = var.vpc_id
}

resource "aws_lb_listener" "private" {
  count             = length(local.private_rule)
  load_balancer_arn = aws_lb.private.arn
  port              = local.private_rule[count.index].port
  protocol          = local.private_rule[count.index].protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.private[count.index].arn
  }
}
