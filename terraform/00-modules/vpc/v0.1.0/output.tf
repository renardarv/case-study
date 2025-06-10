output "subnet_cidrs_public" {
  description = "Public subnet EKS control plane."
  value       = aws_subnet.public_subnet.*.cidr_block
}

output "subnet_cidrs_private" {
  description = "Private subnet EKS control plane."
  value       = aws_subnet.private_subnet.*.cidr_block
}

output "subnet_cidrs_private_id" {
  description = "Private subnet EKS control plane."
  value       = aws_subnet.private_subnet.*.id
}

output "vpc_cidr" {
  description = "VPC cidr block output."
  value       = var.stand_vpc ? aws_vpc.vpc[0].cidr_block : ""
}

output "vpc_id" {
  description = "VPC id output."
  value       = var.stand_vpc ? aws_vpc.vpc[0].id : ""
}
