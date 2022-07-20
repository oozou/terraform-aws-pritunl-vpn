# Change Log

All notable changes to this module will be documented in this file.

## [1.1.0] - 2022-07-21

Here we would have the update steps for 1.1.0 for people to follow.

### Added

- Feature
  - support Auto Recovery when failed (with autoscaling group)
  - private instance with Public, Private Loadbalancer
  - EFS for Mongo
  - Custom DNS for VPN (public, private)
  - Support AWS SSM

- New Resources
  - `aws_autoscaling_group`
  - module `terraform-aws-efs`
  - `aws_iam_role`, `aws_iam_role_policy`, `aws_iam_instance_profile`
  - `launch_template`
  - `aws_lb`
  - `aws_lb_target_group`
  - `aws_route53_record`

- new variables (Optional)
  - `is_create_security_group`
  - `public_subnet_ids`
  - `private_subnet_ids`
  - `public_rule`
  - `private_rule`
  - `is_create_route53_reccord`
  - `public_lb_vpn_domain`
  - `private_lb_vpn_domain`
  - `route53_zone_name`
  - `is_enabled_https_public`
  - `custom_https_allow_cidr`

### Changed

- Variables
  - `key_name` from require variable to optional (because managed by ssm)

### Removed

- Resources
  - module `terraform-aws-ec2-instance.git`

- Variables
  - `subnet_id`

## [1.0.1] - 2022-06-01

### Added

- init terraform-aws-pritunl-vpn module
