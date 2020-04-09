variable "devenv_name" {
  default = "cheapdevenv"
  description = "Controls the naming of the AWS resources."
}

variable "access_key" {
  default = ""
}

variable "secret_key" {
  default = ""
}

variable "ssh_key" {
  description = "Name of SSH public key you used under AWS > EC2 > Key pairs web console."
}

variable "developer_cidr_blocks" {
  description = "A comma separated list of CIDR blocks to allow SSH connections from."
}

variable "region" {
  default = "us-east-1"
}

variable "az" {
  default = "a"
}

variable "remotedevenv_instance_type" {
  default = "m1.small"
  description = "Which EC2 instance type to use for the remotedevenv instance."
}

variable "remotedevenv_spot_price" {
  default = "0.01"
  description = "The maximum spot bid for the remotedevenv instance."
}
