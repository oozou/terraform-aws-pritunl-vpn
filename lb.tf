# LoadBalancer Public
resource "aws_lb" "public" {
  name               = format("%s-public-lb", local.name)
  internal           = false
  load_balancer_type = "network"
  subnets            = var.subnet_ids

  tags = merge(
    { Name = format("%s-lb", local.name) },
    local.tags
  )
}

resource "aws_lb_target_group" "public" {
  count    = length(var.public_rule)
  name     = format("%s-public-tg", local.name)
  port     = var.public_rule[count.index].port
  protocol = var.public_rule[count.index].protocol
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "public" {
  count             = length(var.public_rule)
  load_balancer_arn = aws_lb.public.arn
  port              = var.public_rule[count.index].port
  protocol          = var.public_rule[count.index].protocol

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
  subnets            = var.subnet_ids

  tags = merge(
    { Name = format("%s-lb", local.name) },
    local.tags
  )
}

resource "aws_lb_target_group" "private" {
  count    = length(var.private_rule)
  name     = format("%s-private-tg", local.name)
  port     = var.private_rule[count.index].port
  protocol = var.private_rule[count.index].protocol
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "private" {
  count             = length(var.private_rule)
  load_balancer_arn = aws_lb.private.arn
  port              = var.private_rule[count.index].port
  protocol          = var.private_rule[count.index].protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.private[count.index].arn
  }
}
