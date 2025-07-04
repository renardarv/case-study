provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-rds-aurora"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# RDS Aurora Module
################################################################################

module "aurora" {
  source = "../../"

  name                        = local.name
  engine                      = "aurora-postgresql"
  engine_version              = "14.13"
  master_username             = "root"
  storage_type                = "aurora-iopt1"
  cluster_monitoring_interval = 30

  instances = {
    1 = {
      instance_class          = "db.r5.2xlarge"
      publicly_accessible     = true
      db_parameter_group_name = "default.aurora-postgresql14"
    }
    2 = {
      identifier     = "static-member-1"
      instance_class = "db.r5.2xlarge"
    }
    3 = {
      identifier     = "excluded-member-1"
      instance_class = "db.r5.large"
      promotion_tier = 15
    }
  }

  endpoints = {
    static = {
      identifier     = "static-custom-endpt"
      type           = "ANY"
      static_members = ["static-member-1"]
      tags           = { Endpoint = "static-members" }
    }
    excluded = {
      identifier       = "excluded-custom-endpt"
      type             = "READER"
      excluded_members = ["excluded-member-1"]
      tags             = { Endpoint = "excluded-members" }
    }
  }

  vpc_id               = "vpc-dev11111"
  db_subnet_group_name = "subnet-dbdev1111"
  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = module.vpc.private_subnets_cidr_blocks
    }
    egress_example = {
      type        = "egress"
      cidr_blocks = ["10.33.0.0/28"]
      description = "Egress to corporate printer closet"
    }
  }

  apply_immediately   = true
  skip_final_snapshot = true

  engine_lifecycle_support = "open-source-rds-extended-support-disabled"

  create_db_cluster_parameter_group      = true
  db_cluster_parameter_group_name        = local.name
  db_cluster_parameter_group_family      = "aurora-postgresql14"
  db_cluster_parameter_group_description = "${local.name} example cluster parameter group"
  db_cluster_parameter_group_parameters = [
    {
      name         = "log_min_duration_statement"
      value        = 4000
      apply_method = "immediate"
      }, {
      name         = "rds.force_ssl"
      value        = 1
      apply_method = "immediate"
    }
  ]

  create_db_parameter_group      = true
  db_parameter_group_name        = local.name
  db_parameter_group_family      = "aurora-postgresql14"
  db_parameter_group_description = "${local.name} example DB parameter group"
  db_parameter_group_parameters = [
    {
      name         = "log_min_duration_statement"
      value        = 4000
      apply_method = "immediate"
    }
  ]

  enabled_cloudwatch_logs_exports = ["postgresql"]
  create_cloudwatch_log_group     = true

  cloudwatch_log_group_tags = {
    Sensitivity = "high"
  }

  create_db_cluster_activity_stream     = true
  db_cluster_activity_stream_kms_key_id = module.kms.key_id
  db_cluster_activity_stream_mode       = "async"

  tags = local.tags
}

