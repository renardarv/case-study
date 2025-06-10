resource "aws_subnet" "public_subnet" {
  count = var.create_public_subnet ? length(var.subnet_cidrs_public) : 0

  vpc_id                  = var.create_vpc ? aws_vpc.vpc[0].id : var.vpc_id
  cidr_block              = var.subnet_cidrs_public[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.azs.names[count.index]

  tags = merge(
    {
      Name = "${var.vpc_name}-pub-sub-${element(split("-", "${data.aws_availability_zones.azs.names[count.index]}"), 2)}",
      Network = "${var.network_name}"
      Env  = "${var.environment}"
    },
    var.additional_tags,
    var.subnet_tags,
    var.public_subnet_tags,
  )
}

resource "aws_subnet" "private_subnet" {
  count = var.create_private_subnet ? length(var.subnet_cidrs_private) : 0

  vpc_id            = var.create_vpc ? aws_vpc.vpc[0].id : var.vpc_id
  cidr_block        = var.subnet_cidrs_private[count.index]
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = merge(
    {
      Name = "${var.vpc_name}-pvt-sub-${element(split("-", "${data.aws_availability_zones.azs.names[count.index]}"), 2)}",
      Network = "${var.network_name}"
      Env  = "${var.environment}"
      Terraform = "True"
    },
    var.additional_tags,
    var.subnet_tags,
    var.private_subnet_tags,
  )
}
