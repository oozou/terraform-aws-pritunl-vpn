output "lb_public_dns" {
  description = "The DNS name of the public load balancer."
  value       = aws_lb.public.dns_name
}

output "lb_private_dns" {
  description = "The DNS name of the private load balancer."
  value       = try(aws_lb.private[0].dns_name, "")
}

output "vpn_public_dns" {
  value       = try(aws_route53_record.public[0].name, aws_lb.public.dns_name)
  description = "public dns for connect vpn server"
}

output "vpn_private_dns" {
  value       = try(aws_route53_record.private[0].name, try(aws_lb.private[0].dns_name, ""))
  description = "private dns for connect vpn server"
}

output "efs_id" {
  description = "The ID that identifies the file system for pritunl vpn"
  value       = module.efs.id
}


output "efs_dns_name" {
  description = "The DNS name for the filesystem"
  value       = module.efs.dns_name
}
