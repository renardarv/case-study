resource "aws_ec2_transit_gateway" "this" {
  description = var.description
  amazon_side_asn = var.amazon_side_asn
  auto_accept_shared_attachments = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  tags = var.tags
}

resource "aws_ec2_transit_gateway_vpc_attachment" "attachments" {
  for_each = var.vpc_attachments

  subnet_ids         = each.value.subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = each.value.vpc_id

  tags = merge(var.tags, {
    Name = "tgw-attachment-${each.key}"
  })
}
