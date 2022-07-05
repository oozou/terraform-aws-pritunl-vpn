output "lb_public_dns" {
  description = "The DNS name of the public load balancer."
  value       = aws_lb.public.dns_name
}

output "lb_private_dns" {
  description = "The DNS name of the private load balancer."
  value       = aws_lb.private.dns_name
}

output "efs_id" {
  description = "The ID that identifies the file system for pritunl vpn"
  value       = module.efs.id
}
