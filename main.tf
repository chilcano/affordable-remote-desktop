// ======================================================
// Networking configuration   
// ======================================================
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags {
    Name = "${var.devenv_name}"
    Environment = "${var.devenv_name}"
  }
}

resource "aws_internet_gateway" "main_gw" {
  vpc_id = "${aws_vpc.main_vpc.id}"

  tags {
    Name = "${var.devenv_name}"
    Environment = "${var.devenv_name}"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  cidr_block = "10.0.100.0/24"
  availability_zone = "${var.region}${var.az}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.devenv_name}"
    Environment = "${var.devenv_name}"
  }
}

resource "aws_route_table" "gw_route_table" {
  vpc_id = "${aws_vpc.main_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main_gw.id}"
  }

  depends_on = ["aws_internet_gateway.main_gw"]

  tags {
    Name = "${var.devenv_name}"
    Environment = "${var.devenv_name}"
  }
}

resource "aws_route_table_association" "public_route_table" {
  subnet_id = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.gw_route_table.id}"
}
// ------------------------------------------------------

// ======================================================
// Security Group and its ingress/egress rules   
// ======================================================
resource "aws_security_group" "sec_group" {
  name = "${var.devenv_name}"
  description = "Allow inbound and outbound traffic"
  vpc_id = "${aws_vpc.main_vpc.id}"

  tags {
    Name = "${var.devenv_name}"
    Environment = "${var.devenv_name}"
  }
}

resource "aws_security_group_rule" "allow_all_from_self" {
  type            = "ingress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  source_security_group_id = "${aws_security_group.sec_group.id}"
  security_group_id = "${aws_security_group.sec_group.id}"
}

resource "aws_security_group_rule" "allow_ssh_from_admin" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks     = "${split(",", var.developer_cidr_blocks)}"
  security_group_id = "${aws_security_group.sec_group.id}"
}

resource "aws_security_group_rule" "allow_https_from_web" {
  type            = "ingress"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.sec_group.id}"
}

resource "aws_security_group_rule" "allow_http_from_web" {
  type            = "ingress"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.sec_group.id}"
}

resource "aws_security_group_rule" "allow_all_out" {
  type            = "egress"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.sec_group.id}"
}
// ------------------------------------------------------

// ======================================================
// Uploading Bash Script as Template   
// ======================================================
data "template_file" "remotedevenv_userdata_tpl" {
  template = "${file("remotedevenv.sh")}"

  vars {
    instancename = "${var.devenv_name}"
  }
}
// ------------------------------------------------------

// ======================================================
// IAM configuration      
// ======================================================
resource "aws_iam_role" "ec2_iam_role" {
  name = "${var.devenv_name}_instance_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "awsi_am_policy" "ec2_ebs_policy" {
  name        = "${var.devenv_name}_instance_policy"
  path        = "/"
  description = "Policy for ${var.devenv_name} instance to allow dynamic provisioning of EBS persistent volumes"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:CreateVolume",
        "ec2:DeleteVolume",
        "ec2:DescribeInstances",
        "ec2:DescribeRouteTables",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVolumes",
        "ec2:DescribeVolumesModifications",
        "ec2:DescribeVpcs",
        "elasticloadbalancing:DescribeLoadBalancers",
        "ec2:DetachVolume",
        "ec2:ModifyVolume",
        "ec2:CreateTags"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_ebs_policy_att" {
  role       = "${aws_iam_role.ec2_iam_role.name}"
  policy_arn = "${aws_iam_policy.ec2_ebs_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy_att" {
  role       = "${aws_iam_role.ec2_iam_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "${var.devenv_name}_instance_profile"
  role = "${aws_iam_role.ec2_iam_role.name}"
}
// ------------------------------------------------------

// ======================================================
// EC2 Spot Instances (Remote Development Environment)
// ======================================================

data "aws_ami" "latest_ami" {
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-instance/ubuntu-bionic-18.04-amd64-server-*"]
  }

  most_recent = true
  owners      = ["099720109477"] # Ubuntu
}

resource "aws_spot_instance_request" "remotedevenv" {
  ami                     = "${data.aws_ami.latest_ami.id}"
  instance_type           = "${var.remotedevenv_instance_type}"
  subnet_id               = "${aws_subnet.public_subnet.id}"
  user_data               = "${data.template_file.remotedevenv_userdata_tpl.rendered}"
  key_name                = "${var.ssh_key}"
  iam_instance_profile    = "${aws_iam_instance_profile.iam_instance_profile.name}"
  vpc_security_group_ids  = ["${aws_security_group.sec_group.id}"]
  spot_price              = "${var.remotedevenv_spot_price}"
  valid_until             = "9999-12-25T12:00:00Z"
  wait_for_fulfillment    = true
  private_ip              = "10.0.100.4"

  depends_on = ["aws_internet_gateway.main_gw"]

  tags {
    Name = "${var.devenv_name}_spot_instance"
    Environment = "${var.devenv_name}_spot_instance"
  }

  lifecycle {
    ignore_changes = ["ami"]
  }
}
// ------------------------------------------------------