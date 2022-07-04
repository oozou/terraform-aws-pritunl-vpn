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
    allow_to_config_vpn = {
      port        = "443"
      cidr_blocks = ["0.0.0.0/0"]
    }
    allow_to_ssh = {
      port        = "22"
      cidr_blocks = ["0.0.0.0/0"]
    }
    allow_to_connect_vpn = {
      port        = "12383"
      cidr_blocks = ["0.0.0.0/0"]
      protocol    = "udp"
    }
  }
}

# variable "availability_zones" {
#   description = "Availability zones for Pritunl VPN server"
#   type        = list(string)
#   default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
# }

variable "is_create_security_group" {
  description = "Flag to toggle security group creation"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "The List of the subnet ID to deploy vpn relate to VPC"
  type        = list(string)
}

variable "key_name" {
  description = "Key name of the Key Pair to use for the vpn instance; which can be managed using"
  type        = string
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

# variable "disk_size" {
#   description = "Disk size for Pritunl VPN server"
#   type        = number
#   default     = 80
# }

# variable "disk_type" {
#   description = "Disk type for Pritunl VPN server"
#   type        = string
#   default     = "gp3"
# }
