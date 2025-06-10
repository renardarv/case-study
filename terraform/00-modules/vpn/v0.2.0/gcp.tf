provider "google" {
  alias   = "gcp"
  project = var.gcp_project
  region  = var.gcp_region
}

resource "google_compute_vpn_gateway" "this" {
  provider = google
  name     = var.gcp_gateway_name
  network  = var.gcp_network
}

resource "google_compute_vpn_tunnel" "aws_tunnel" {
  provider               = google
  name                   = "${var.prefix}-to-aws-tunnel"
  vpn_gateway            = google_compute_vpn_gateway.this.name
  peer_external_gateway  = var.aws_gateway_ip
  shared_secret          = var.shared_secret
  ike_version            = 2
  region                 = var.gcp_region
  local_traffic_selector = var.gcp_cidr_blocks
  remote_traffic_selector = var.aws_cidr_blocks
}

resource "google_compute_route" "to_aws" {
  provider        = google
  for_each        = toset(var.aws_cidr_blocks)
  name            = "route-to-aws-${replace(each.value,"/","-")}"
  network         = var.gcp_network
  dest_range      = each.value
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.aws_tunnel.self_link
  priority        = 1000
}