provider "aws" {
  alias  = "aws"
  region = var.aws_region
}

resource "aws_vpn_gateway" "this" {
  provider = aws
  vpc_id   = var.aws_vpc_id
  tags     = var.tags
}

resource "aws_customer_gateway" "this" {
  provider   = aws
  bgp_asn     = var.aws_cgw_bgp_asn
  ip_address = var.gcp_gateway_ip
  type        = "ipsec.1"
  tags        = var.tags
}

resource "aws_vpn_connection" "this" {
  provider            = aws
  customer_gateway_id = aws_customer_gateway.this.id
  vpn_gateway_id      = aws_vpn_gateway.this.id
  type                = "ipsec.1"
  static_routes_only  = true
  tags                = var.tags
}

resource "aws_vpn_connection_route" "gcp_routes" {
  provider             = aws
  for_each             = toset(var.gcp_cidr_blocks)
  vpn_connection_id    = aws_vpn_connection.this.id
  destination_cidr_block = each.value
}
