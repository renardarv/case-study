module "zone_cross_account_vpc_association" {
  source = "../../modules/zone-cross-account-vpc-association"
  providers = {
    aws.r53_owner = aws
    aws.vpc_owner = aws.second_account
  }

  zone_vpc_associations = {
    example = {
      zone_id = module.zones.route53_zone_zone_id["private-vpc.terraform-aws-modules-example.com"]
      vpc_id  = module.vpc_otheraccount.vpc_id
    },
    example2 = {
      zone_id    = module.zones.route53_zone_zone_id["private-vpc.terraform-aws-modules-example2.com"]
      vpc_id     = module.vpc_otheraccount.vpc_id
      vpc_region = data.aws_region.second_account_current.name
    },
  }
}