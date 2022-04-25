output "public_ip" {
  description = "public ip for access vpn server"
  value       = module.ec2.public_ip
}
