provider "aws" {
  region = "us-east-1"
}

provider "google" {
  project = "my-gcp-project"
  region  = "us-central1"
}

// Allocate a static IP on GCP for the VPN gateway
resource "google_compute_address" "vpn_ip" {
  name   = "gcp-vpn-ip"
  region = "us-central1"
}

module "site_to_site_vpn" {
  source           = "../../modules/site_to_site_vpn"

  aws_region       = "us-east-1"
  aws_vpc_id       = "vpc-0123456789abcdef0"
  aws_cidr_blocks  = ["10.0.0.0/16"]
  aws_cgw_bgp_asn  = 65000
  aws_gateway_ip   = aws_vpn_gateway.test.public_ip // assume you created aws_vpn_gateway manually

  gcp_project      = "my-gcp-project"
  gcp_region       = "us-central1"
  gcp_network      = "default"
  gcp_gateway_ip   = google_compute_address.vpn_ip.address
  gcp_gateway_name = "gcp-vpn-gw"
  gcp_cidr_blocks  = ["10.1.0.0/16"]

  shared_secret    = var.shared_secret
  prefix           = "awsgcpvpn"
  tags             = {
    Environment = "prod"
    Project     = "networking"
  }
}
