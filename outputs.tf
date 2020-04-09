output "remotedevenv_fqdn" {
  value = "${aws_spot_instance_request.remotedevenv.public_dns}"
}
