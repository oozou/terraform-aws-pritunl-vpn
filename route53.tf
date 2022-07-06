data "aws_route53_zone" "this" {
  count = var.is_create_route53_reccord ? 1 : 0
  name  = var.route53_zone_name
}

resource "aws_route53_record" "public" {
  count   = var.is_create_route53_reccord ? 1 : 0
  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = format("%s.%s", var.public_lb_vpn_domain, var.route53_zone_name)
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.public.dns_name]
}

resource "aws_route53_record" "private" {
  count   = var.is_create_route53_reccord ? 1 : 0
  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = format("%s.%s", var.private_lb_vpn_domain, var.route53_zone_name)
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.private.dns_name]
}
