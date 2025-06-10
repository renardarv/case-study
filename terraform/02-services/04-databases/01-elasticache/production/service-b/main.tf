provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  region = "ap-southeast-1"
  name   = "ex-${basename(path.cwd)}"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Name       = local.name
    Example    = local.name
  }
}

################################################################################
# ElastiCache Module
################################################################################

module "elasticache" {
  source = "../../"

  cluster_id               = local.name
  create_cluster           = true
  create_replication_group = false

  engine_version = "7.1"
  node_type      = "cache.t4g.small"

  maintenance_window = "sun:05:00-sun:09:00"
  apply_immediately  = true

  # Security Group
  vpc_id = "vpc-dev11111"
  security_group_rules = {
    ingress_vpc = {
      # Default type is `ingress`
      # Default port is based on the default engine port
      description = "VPC traffic"
      cidr_ipv4   = "16.0.0.0/16"
    }
  }

  # Subnet Group
  subnet_group_name        = local.name
  subnet_group_description = "${title(local.name)} subnet group"
  subnet_ids               = ["subnet-dev1111", "subnet-dev2222"]

  # Parameter Group
  create_parameter_group      = true
  parameter_group_name        = local.name
  parameter_group_family      = "redis7"
  parameter_group_description = "${title(local.name)} parameter group"
  parameters = [
    {
      name  = "latency-tracking"
      value = "yes"
    }
  ]

  tags = local.tags

  timeouts = {
    create = "1h"
    update = "2h"
    delete = "1h"
  }
}
