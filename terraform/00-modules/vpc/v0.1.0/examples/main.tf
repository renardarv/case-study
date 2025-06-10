module "vpc" {

  source = "../"

  create_vpc               = true
  vpc_name                 = "example-vpc"
  network_name             = "example-network"
  environment              = "example"
  vpc_cidr                 = "16.0.0.0/16"
  vpc_enable_dns_support   = true
  vpc_enable_dns_hostnames = true

  create_public_subnet_to_route_table = true
  attach_public_subnet_to_route_table = true
  create_private_subnet               = true

  subnet_cidrs_public  = ["16.0.11.0/24", "16.0.12.0/24"]
  subnet_cidrs_private = ["16.0.21.0/24"]

  create_internet_gateway   = true
  enable_internet_gateway   = true
  enable_single_nat_gateway = true
}
