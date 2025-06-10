locals {

  stand    = var.stand_vpc ? aws_vpc.vpc[0].id : ""
  variable = var.vpc_id != "" && var.attach_internet_gateway ? var.vpc_id : ""

}

resource "aws_internet_gateway" "internet_gateway" {

  count = var.create_internet_gateway ? 1 : 0

  vpc_id = coalesce(local.stand, local.variable)

  tags = merge(
    {
      Name    = "${var.vpc_name}-igw"
      Network = "${var.network_name}"
      Env     = "${var.environment}"
      Terraform = "True"
    },
    var.additional_tags,
    var.internet_gateway_tags,
  )

}
