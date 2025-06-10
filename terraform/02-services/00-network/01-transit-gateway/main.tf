provider "aws" {
  region = "us-east-1"
}

module "tgw" {
  source = "../../../../00-modules/transit-gateway/v0.2.0"

  description = "Central TGW"
  amazon_side_asn = 64512
  tags = {
    Environment = "shared"
    Project     = "network-core"
  }

  vpc_attachments = {
    global = {
      vpc_id     = "vpc-0123456789abcdef0"
      subnet_ids = ["subnet-global111", "subnet-global222"]
    }
    development = {
      vpc_id     = "vpc-2222222222abcdef0"
      subnet_ids = ["subnet-dev111", "subnet-dev222"]
    }
    staging = {
      vpc_id     = "vpc-3333333333abcdef0"
      subnet_ids = ["subnet-stage111", "subnet-stage222"]
    }
    production = {
      vpc_id     = "vpc-4444444444abcdef0"
      subnet_ids = ["subnet-prod111", "subnet-prod222"]
    }
  }
}
