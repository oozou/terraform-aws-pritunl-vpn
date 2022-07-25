output "vpn_public_dns" {
  value       = module.vpn.vpn_public_dns
  description = "public dns for connect vpn server"
}

output "vpn_private_dns" {
  value       = module.vpn.vpn_private_dns
  description = "private dns for connect vpn server"
}
