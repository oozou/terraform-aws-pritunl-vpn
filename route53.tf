data "aws_route53_zone" "this" {
  count = var.is_create_route53_reccord && var.is_create_lb ? 1 : 0
  name  = var.route53_zone_name
}

resource "aws_route53_record" "public" {
  count   = var.is_create_route53_reccord && var.is_create_lb ? 1 : 0
  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = format("%s.%s", var.public_lb_vpn_domain, var.route53_zone_name)
  type    = "A"
  alias {
    name                   = aws_lb.public[0].dns_name
    zone_id                = aws_lb.public[0].zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "private" {
  count   = var.is_create_private_lb && var.is_create_route53_reccord ? 1 : 0
  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = format("%s.%s", var.private_lb_vpn_domain, var.route53_zone_name)
  type    = "A"
  alias {
    name                   = aws_lb.private[0].dns_name
    zone_id                = aws_lb.private[0].zone_id
    evaluate_target_health = true
  }
}
