# Public Webserver IPs
output "public_webserver_ips" {
  description = "Public IP addresses of the webservers"
  value       = aws_instance.webservers[*].public_ip
}

# Private Webserver IPs
output "private_webserver_ips" {
  description = "Private IP addresses of the private webservers"
  value       = aws_instance.private_webservers[*].private_ip
}

# Bastion Host Public IP
output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = aws_instance.bastion.public_ip
}

# ALB DNS Name
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.webserver.dns_name
}