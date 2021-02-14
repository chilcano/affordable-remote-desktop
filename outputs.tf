output "remotedesktop_fqdn" {
  value = aws_spot_instance_request.remotedesktop.public_dns
}
