## Create VPC
resource "aws_vpc" "vpc" {
  count                            = var.create_vpc ? 1 : 0
  cidr_block                       = var.vpc_cidr
  enable_dns_support               = var.vpc_enable_dns_support
  enable_dns_hostnames             = var.vpc_enable_dns_hostnames
  # enable_classiclink               = false
  # enable_classiclink_dns_support   = false
  assign_generated_ipv6_cidr_block = false

  tags = merge(
    {
      Name = "${var.vpc_name}"
      Network = "${var.network_name}"
      Env  = "${var.environment}"
      Terraform = "True"
    },
    var.additional_tags,
    var.vpc_tags,
  )
}

## Create elastic IP
resource "aws_eip" "single_elastic_ip" {
  count = var.enable_single_nat_gateway && !var.enable_foreach_nat_gateway ? 1 : 0
  vpc   = true
}

resource "aws_eip" "foreach_elastic_ip" {
  count = var.enable_foreach_nat_gateway && !var.enable_single_nat_gateway ? length(var.subnet_cidrs_public) : 0
  vpc   = true
}

## Create subnet availability
data "aws_availability_zones" "azs" {
  state = "available"
}
