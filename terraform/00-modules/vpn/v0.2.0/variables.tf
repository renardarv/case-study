variable "aws_region" {
  type        = string
  description = "Region for AWS resources"
}

variable "aws_vpc_id" {
  type        = string
  description = "VPC ID for AWS side"
}

variable "aws_cgw_bgp_asn" {
  type        = number
  description = "BGW ASN for AWS Customer Gateway"
  default     = 65000
}

variable "gcp_gateway_ip" {
  type        = string
  description = "External IP of GCP VPN Gateway or Peer Gateway"
}

variable "gcp_project" {
  type        = string
  description = "GCP Project ID"
}

variable "gcp_region" {
  type        = string
  description = "Region for GCP resources"
}

variable "gcp_network" {
  type        = string
  description = "GCP VPC network name"
}

variable "gcp_gateway_name" {
  type        = string
  description = "Name for GCP VPN Gateway"
}

variable "shared_secret" {
  type        = string
  description = "Pre-shared key for IPsec tunnel"
  sensitive   = true
}

variable "gcp_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks in GCP VPC"
}

variable "aws_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks in AWS VPC"
}

variable "aws_gateway_ip" {
  type        = string
  description = "External IP of AWS VPN Gateway"
}

variable "prefix" {
  type        = string
  description = "Prefix for naming resources"
  default     = "st2svpn"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to AWS resources"
  default     = {}
}