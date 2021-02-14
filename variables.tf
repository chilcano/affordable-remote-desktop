variable "node_name" {
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

variable "remotedesktop_instance_type" {
  default = "m1.small"
  description = "Which EC2 instance type to use for the remotedesktop instance."
}

variable "remotedesktop_spot_price" {
  default = "0.01"
  description = "The maximum spot bid for the remotedesktop instance."
}

variable "ami_name_filter" {
  //default = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"          # Ubuntu
  //default = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"           # Ubuntu
  default = "chilcano/images/hvm-ssd/ubuntu-bionic-18.04-amd64-gui-*"           # Chilcano
  description = "AMI Name Filter."
}

variable "ami_owner" {
  //default = "099720109477"     # Ubuntu
  default = "263455585760"     # Chilcano
  description = "AMI Owner." 
}
