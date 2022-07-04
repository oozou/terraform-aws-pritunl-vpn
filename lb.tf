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
  name     = format("%s-public-tg", local.name)
  port     = 12383
  protocol = "UDP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "vpn" {
  load_balancer_arn = aws_lb.public.arn
  port              = "12383"
  protocol          = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public.arn
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
  name     = format("%s-private-tg", local.name)
  port     = 443
  protocol = "TCP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.private.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.private.arn
  }
}
