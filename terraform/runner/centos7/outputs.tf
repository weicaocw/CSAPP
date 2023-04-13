output "private_key" {
  sensitive = true
  value     = module.ec2_spot_cluster.private_key
}

output "fleet_request" {
  value = module.ec2_spot_cluster.fleet_request
}
