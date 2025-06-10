module "vpc" {

  source = "../../../../00-modules/vpc/v0.2.0"

  create_vpc               = true
  vpc_name                 = "vpc-global"
  network_name             = "global"
  environment              = "global"
  vpc_cidr                 = "16.0.0.0/16"
  vpc_enable_dns_support   = true
  vpc_enable_dns_hostnames = true

  create_public_subnet_to_route_table = true
  attach_public_subnet_to_route_table = true
  create_private_subnet               = true

  subnet_cidrs_public  = ["16.0.11.0/24", "16.0.12.0/24"]
  subnet_cidrs_private = ["16.0.21.0/24", "16.0.31.0/24"]

  create_internet_gateway   = true
  enable_internet_gateway   = true
  enable_single_nat_gateway = true
}
