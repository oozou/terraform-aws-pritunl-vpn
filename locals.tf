locals {
  tags = merge(
    {
      "Environment" = var.environment,
      "Terraform"   = "true"
    },
    var.tags
  )

  name = format("%s-%s-%s", var.prefix, var.environment, "pritunl-vpn")
}
