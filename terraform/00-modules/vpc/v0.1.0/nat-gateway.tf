resource "aws_nat_gateway" "single_nat_gateway" {

  count = var.enable_single_nat_gateway && !var.enable_foreach_nat_gateway ? 1 : 0

  depends_on = [
    aws_subnet.public_subnet[0],
    aws_eip.single_elastic_ip,
  ]

  allocation_id = aws_eip.single_elastic_ip[0].id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = merge(
    {
      Name = "${var.vpc_name}-single-ngw"
      Network = "${var.network_name}"
      Env  = "${var.environment}"
      Terraform = "True"
    },
    var.additional_tags,
    var.nat_gateway_tags,
  )

}

resource "aws_nat_gateway" "foreach_nat_gateway" {

  count = var.enable_foreach_nat_gateway && !var.enable_single_nat_gateway ? length(var.subnet_cidrs_public) : 0

  depends_on = [
    aws_subnet.public_subnet,
    aws_eip.foreach_elastic_ip,
  ]

  allocation_id = aws_eip.foreach_elastic_ip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = merge(
    {
      Name = "${var.vpc_name}-foreach-ngw"
      Network = "${var.network_name}"
      Env  = "${var.environment}"
      Terraform = "True"
    },
    var.additional_tags,
    var.nat_gateway_tags,
  )

}
