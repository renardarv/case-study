module "vpc" {
  source = "../../../../00-modules/vpc/v0.2.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 3, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k + 10)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k + 13)]

  enable_single_nat_gateway = true
  vpc_enable_dns_hostnames  = true
  vpc_enable_dns_support    = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
    "karpenter.sh/discovery"                      = local.name
    "Usage"                                       = "${local.name}-pods"
  }

  tags = local.tags
}
