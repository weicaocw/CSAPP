output "key_pair" {
  description = "Key pair used to login to cluster instances"
  value       = aws_key_pair.cluster_key_pair.key_name
}

output "fleet_request" {
  description = "EC2 spot fleet request to manage the cluster"
  value       = aws_spot_fleet_request.fleet_request.id
}

output "cluster_id" {
  description = "ID used to identify the cluster"
  value       = var.cluster_id
}

output "private_key" {
  sensitive = true
  value     = tls_private_key.cluster_priv_key.private_key_pem
}
