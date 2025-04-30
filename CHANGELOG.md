# Change Log

All notable changes to this module will be documented in this file.

## [1.4.0] - 2025-04-29

### Added

- Example: without_alb
- Add public alb condition to support creating pritunl vpn without Public ALB
- Support create pritunl vpn ec2 on public subnet

## [1.3.2] - 2025-03-31

### Updated

- Change AMI owner

## [1.3.0] - 2024-09-25

### Added

- Install packages libpkcs11-helper.so.1()(64bit) to user-data.sh

## [1.2.2] - 2022-11-08

### Changed 

- update output alb
  
## [1.1.7] - 2022-11-08

### Changed 

- Update module `efs` to be public and version `v1.0.1` to `v1.0.4`

## [1.1.6] - 2022-10-21

### Added

- Add output `security_group_id` and `security_group_arn`

## [1.1.5] - 2022-09-27

### Changed 

- change launch-template module from ssh to public
- change launch-temaplte module from version 1.1.2 to 1.1.3

## [1.1.4] - 2022-09-08

### Changed 

- Update provider version to `>= 4.0.0` in both files `examples/complete/versions.tf` and `versions.tf`

## [1.1.3] - 2022-09-07

### Changed

- Update module `efs` to be public and version `v1.0.1` to `v1.0.3`
- Enable encryption in module `efs` with `encrypted = true`
- Update example

## [1.1.2] - 2022-08-30

Here we would have the update steps for 1.1.2 for people to follow.

### Added

- variables
  - `is_create_private_lb`
- support route53 alias

### Changed

- change 443 health check to TCP by default

## [1.1.1] - 2022-08-10

Here we would have the update steps for 1.1.1 for people to follow.

### Added

- new variables (Optional)
  - `enable_ec2_monitoring`

## [1.1.0] - 2022-07-27

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
