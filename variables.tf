variable "prefix" {
  description = "The prefix name of customer to be displayed in AWS console and resource"
  type        = string
}

variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
}

variable "tags" {
  description = "Tags to add more; default tags contian {terraform=true, environment=var.environment}"
  type        = map(string)
  default     = {}
}

variable "instance_type" {
  description = "(Optional) The instance type to use for the instance. Updates to this field will trigger a stop/start of the EC2 instance."
  type        = string
  default     = "t2.medium"
}

variable "security_group_ingress_rules" {
  description = "Map of ingress and any specific/overriding attributes to be created"
  type        = any
  default = {
    allow_to_connect_vpn = {
      port        = "12383"
      cidr_blocks = ["0.0.0.0/0"]
      protocol    = "udp"
    }
  }
}

variable "is_create_security_group" {
  description = "Flag to toggle security group creation"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "The List of the subnet ID to deploy Public Loadbalancer relate to VPC"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "The List of the private subnet ID to deploy instance and private lb for vpn relate to VPC"
  type        = list(string)
}

variable "key_name" {
  description = "Key name of the Key Pair to use for the vpn instance; which can be managed using"
  type        = string
  default     = null
}

variable "additional_sg_attacment_ids" {
  description = "(Optional) The ID of the security group."
  type        = list(string)
  default     = []
}

variable "ami" {
  type        = string
  description = "(Optional) AMI to use for the instance. Required unless launch_template is specified and the Launch Template specifes an AMI. If an AMI is specified in the Launch Template, setting ami will override the AMI specified in the Launch Template"
  default     = ""
}

variable "public_rule" {
  description = "public rule for run connect vpn"
  type = list(object({
    port                  = number
    protocol              = string
    health_check_port     = number
    health_check_protocol = string
  }))
  default = [
    {
      port                  = 12383
      protocol              = "UDP"
      health_check_port     = 443
      health_check_protocol = "TCP"
    }
  ]
}

variable "private_rule" {
  description = "private rule for run connect vpn"
  type = list(object({
    port                  = number
    protocol              = string
    health_check_port     = number
    health_check_protocol = string
  }))
  default = []
}

variable "is_create_route53_reccord" {
  description = "if true will create route53 reccord for vpn, vpn console"
  type        = bool
  default     = false
}

variable "public_lb_vpn_domain" {
  description = "domain of vpn output will be <var.vpn_domain>.<var.route53_zone_name>"
  type        = string
  default     = "vpn"
}

variable "private_lb_vpn_domain" {
  description = "domain of vpn console output will be <var.vpn_domain>.<var.route53_zone_name>"
  type        = string
  default     = "vpn-console"
}

variable "route53_zone_name" {
  description = "This is the name of the hosted zone"
  type        = string
  default     = ""
}

variable "is_enabled_https_public" {
  description = "if true will enable https to public loadbalancer else enable to private loadbalancer"
  type        = bool
  default     = true
}

variable "custom_https_allow_cidr" {
  description = "cidr block for config pritunl vpn"
  type        = list(string)
  default     = null
}

variable "enabled_backup" {
  type        = bool
  description = "Enable Backup EFS"
  default     = true
}

variable "efs_backup_policy_enabled" {
  type        = bool
  description = "If `true`, it will turn on automatic backups."
  default     = true
}
