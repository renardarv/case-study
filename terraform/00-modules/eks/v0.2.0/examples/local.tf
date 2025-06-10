data "aws_availability_zones" "available" {}

locals {
  name         = "inno-k8s-prod"
  cluster_name = "inno-k8s-prod"
  region       = "eu-central-1"

  vpc_cidr = "10.36.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint                = local.name
    Terraform                = "True"
    "karpenter.sh/discovery" = local.name
  }
}
