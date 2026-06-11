output "web_server_instance_id" {
  description = "ID of the EC2 instance"
  value       = module.web_server.instance_id
}

output "web_server_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.web_server.instance_public_ip
}

output "web_server_url" {
  description = "URL for the ABSA status page"
  value       = "http://${module.web_server.instance_public_ip}"
}

output "web_server_security_group_id" {
  description = "Security group ID attached to the EC2 instance"
  value       = module.web_server.security_group_id
}