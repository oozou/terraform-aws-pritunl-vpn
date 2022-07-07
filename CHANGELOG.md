# Change Log

All notable changes to this module will be documented in this file.

## [1.1.0] - 2022-07-07

Here we would have the update steps for 1.1.0 for people to follow.

### Added

- Feature
  - private instance with Public, Private Loadbalancer
  - support Auto Recovery when failed
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
  - `cloudwatch_log_kms_key_id`
  - `cloudwatch_log_retention_in_days`

### Changed

- Rename `cluster_log_retention_in_days` to `cloudwatch_log_kms_key_id`

## [1.0.1] - 2022-06-01

### Removed

### Added

- init terraform-aws-pritunl-vpn module
