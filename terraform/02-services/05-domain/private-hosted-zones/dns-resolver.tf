module "resolver_rule_associations" {
  source = "../../modules/resolver-rule-associations"

  vpc_id = module.vpc1.vpc_id

  resolver_rule_associations = {
    example = {
      resolver_rule_id = aws_route53_resolver_rule.sys.id
    },
    example2 = {
      name             = "example2"
      resolver_rule_id = aws_route53_resolver_rule.sys.id
      vpc_id           = module.vpc2.vpc_id
    },
  }
}

module "inbound_resolver_endpoints" {
  source = "../../modules/resolver-endpoints"

  name      = "example1"
  direction = "INBOUND"
  protocols = ["Do53", "DoH"]

  subnet_ids = slice(module.vpc1.private_subnets, 0, 2)

  vpc_id                     = module.vpc1.vpc_id
  security_group_name_prefix = "example1-sg-"
  security_group_ingress_cidr_blocks = [
    module.vpc2.vpc_cidr_block
  ]
  security_group_egress_cidr_blocks = [
    module.vpc2.vpc_cidr_block
  ]
}

module "outbound_resolver_endpoints" {
  source = "../../modules/resolver-endpoints"

  name      = "example2"
  direction = "OUTBOUND"
  protocols = ["Do53", "DoH"]

  # Using fixed IP addresses
  ip_address = [
    {
      ip        = "10.0.0.35"
      subnet_id = module.vpc1.private_subnets[0]
    },
    {
      ip        = "10.0.1.35"
      subnet_id = module.vpc1.private_subnets[1]
    }
  ]

  vpc_id                     = module.vpc1.vpc_id
  security_group_name_prefix = "example2-sg-"
  security_group_ingress_cidr_blocks = [
    module.vpc1.vpc_cidr_block
  ]
  security_group_egress_cidr_blocks = [
    module.vpc2.vpc_cidr_block
  ]
}
