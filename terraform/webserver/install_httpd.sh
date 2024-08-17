#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "<h1>Hello from ACS730 Webserver</h1>" > /var/www/html/index.html
echo "<p>Environment: ${env}</p>" >> /var/www/html/index.html
echo "<p>Public IP: $PUBLIC_IP</p>" >> /var/www/html/index.html