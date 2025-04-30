<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | git@github.com:oozou/terraform-aws-vpc.git | v1.1.6 |
| <a name="module_vpn"></a> [vpn](#module\_vpn) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment Variable used as a prefix | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix name of customer to be displayed in AWS console and resource | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to add more; default tags contian {terraform=true, environment=var.environment} | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpn_private_dns"></a> [vpn\_private\_dns](#output\_vpn\_private\_dns) | private dns for connect vpn server |
| <a name="output_vpn_public_dns"></a> [vpn\_public\_dns](#output\_vpn\_public\_dns) | public dns for connect vpn server |
<!-- END_TF_DOCS -->
