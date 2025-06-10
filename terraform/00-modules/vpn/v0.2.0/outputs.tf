output "aws_vpn_connection_id" {
  value       = aws_vpn_connection.this.id
  description = "ID of the AWS VPN Connection"
}

output "gcp_vpn_tunnel_name" {
  value       = google_compute_vpn_tunnel.aws_tunnel.name
  description = "Name of the GCP VPN Tunnel"
}