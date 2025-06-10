module "zones" {
  source = "../../modules/zones"

  zones = {
    "terraform-aws-modules-example.com" = {
      comment = "terraform-aws-modules-example.com (production)"
      tags = {
        Name = "terraform-aws-modules-example.com"
      }
      timeouts = {
        create = "2h"
        update = "3h"
        delete = "1h"
      }
    }

    "app.terraform-aws-modules-example.com" = {
      comment = "app.terraform-aws-modules-example.com"
      # delegation_set_id = module.delegation_sets.route53_delegation_set_id.main
      tags = {
        Name = "app.terraform-aws-modules-example.com"
      }
    }

    "private-vpc.terraform-aws-modules-example.com" = {
      # in case than private and public zones with the same domain name
      domain_name = "terraform-aws-modules-example.com"
      comment     = "private-vpc.terraform-aws-modules-example.com"
      vpc = [
        {
          vpc_id = module.vpc1.vpc_id
        },
        {
          vpc_id = module.vpc2.vpc_id
        },
      ]
      tags = {
        Name = "private-vpc.terraform-aws-modules-example.com"
      }
    }

    "private-vpc.terraform-aws-modules-example2.com" = {
      # in case than private and public zones with the same domain name
      domain_name = "terraform-aws-modules-example2.com"
      comment     = "private-vpc.terraform-aws-modules-example2.com"
      vpc = [
        {
          vpc_id = module.vpc1.vpc_id
        },
      ]
      tags = {
        Name = "private-vpc.terraform-aws-modules-example2.com"
      }
    }

  }

  tags = {
    ManagedBy = "Terraform"
  }
}

module "records" {
  source = "../../modules/records"

  zone_name = local.zone_name
  #  zone_id = local.zone_id

  records = [
    {
      name            = ""
      type            = "SOA"
      ttl             = 900
      allow_overwrite = true # SOA record already exist in the zone
      records = [
        "${module.zones.primary_name_server[local.zone_name]}. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 60",
      ]
      timeouts = {
        create = "2h"
        update = "2h"
        delete = "1h"
      }
    },
    {
      name = ""
      type = "A"
      ttl  = 3600
      records = [
        "10.10.10.10",
      ]
      set_identifier = "dev"
      cidr_routing_policy = {
        collection_id = aws_route53_cidr_collection.example.id
        location_name = "*"
      }
    },
    {
      key  = "s3-bucket"
      name = "s3-bucket-${module.s3_bucket.s3_bucket_hosted_zone_id}"
      type = "A"
      alias = {
        name    = module.s3_bucket.s3_bucket_website_domain
        zone_id = module.s3_bucket.s3_bucket_hosted_zone_id
      }
    },
    {
      name = ""
      type = "MX"
      ttl  = 3600
      records = [
        "1 aspmx.l.google.com",
        "5 alt1.aspmx.l.google.com",
        "5 alt2.aspmx.l.google.com",
        "10 alt3.aspmx.l.google.com",
        "10 alt4.aspmx.l.google.com"
      ]
    },
    {
      name           = "geo"
      type           = "CNAME"
      ttl            = 5
      records        = ["europe.test.example.com."]
      set_identifier = "europe"
      geolocation_routing_policy = {
        continent = "EU"
      }
    },
    {
      name           = "geoproximity-aws-region"
      type           = "CNAME"
      ttl            = 5
      records        = ["us-east-1.test.example.com."]
      set_identifier = "us-east-1-region"
      geoproximity_routing_policy = {
        aws_region = "us-east-1"
        bias       = 0
      }
    },
    {
      name           = "geoproximity-coordinates"
      type           = "CNAME"
      ttl            = 5
      records        = ["nyc.test.example.com."]
      set_identifier = "nyc"
      geoproximity_routing_policy = {
        coordinates = {
          latitude  = "40.71"
          longitude = "-74.01"
        }
      }
    },
    {
      name = "cloudfront"
      type = "A"
      alias = {
        name    = module.cloudfront.cloudfront_distribution_domain_name
        zone_id = module.cloudfront.cloudfront_distribution_hosted_zone_id
      }
    },
    {
      name = "cloudfront"
      type = "AAAA"
      alias = {
        name    = module.cloudfront.cloudfront_distribution_domain_name
        zone_id = module.cloudfront.cloudfront_distribution_hosted_zone_id
      }
    },
    {
      name           = "test"
      type           = "CNAME"
      ttl            = 5
      records        = ["test.example.com."]
      set_identifier = "test-primary"
      weighted_routing_policy = {
        weight = 90
      }
    },
    {
      name           = "test"
      type           = "CNAME"
      ttl            = 5
      records        = ["test2.example.com."]
      set_identifier = "test-secondary"
      weighted_routing_policy = {
        weight = 10
      }
    },
    {
      name            = "failover-primary"
      type            = "A"
      set_identifier  = "failover-primary"
      health_check_id = aws_route53_health_check.failover.id
      alias = {
        name    = module.cloudfront.cloudfront_distribution_domain_name
        zone_id = module.cloudfront.cloudfront_distribution_hosted_zone_id
      }
      failover_routing_policy = {
        type = "PRIMARY"
      }
    },
    {
      name           = "failover-secondary"
      type           = "A"
      set_identifier = "failover-secondary"
      alias = {
        name    = module.s3_bucket.s3_bucket_website_domain
        zone_id = module.s3_bucket.s3_bucket_hosted_zone_id
      }
      failover_routing_policy = {
        type = "SECONDARY"
      }
    },
    {
      name           = "latency-test"
      type           = "A"
      set_identifier = "latency-test"
      alias = {
        name                   = module.cloudfront.cloudfront_distribution_domain_name
        zone_id                = module.cloudfront.cloudfront_distribution_hosted_zone_id
        evaluate_target_health = true
      }
      latency_routing_policy = {
        region = "eu-west-1"
      }
    }
  ]

  depends_on = [module.zones]
}