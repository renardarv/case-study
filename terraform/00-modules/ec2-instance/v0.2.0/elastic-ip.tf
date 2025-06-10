resource "aws_eip" "this" {
  count = local.create && var.create_eip && !var.create_spot_instance ? 1 : 0

  instance = try(
    aws_instance.this[0].id,
    aws_instance.ignore_ami[0].id,
  )

  domain = var.eip_domain

  tags = merge(var.tags, var.eip_tags)
}
