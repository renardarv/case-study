data "aws_availability_zones" "available" {}

locals {
  name         = "eks-stag"
  cluster_name = "eks-stag"
  region       = "ap-southeast-1"

  vpc_cidr = "195.36.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint                = local.name
    Terraform                = "True"
    "karpenter.sh/discovery" = local.name
  }
}
