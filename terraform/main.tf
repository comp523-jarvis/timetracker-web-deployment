terraform {
  backend "s3" {
    bucket               = "ulimi-terraform-state"
    dynamodb_table       = "terraform-lock"
    key                  = "timetracker-web"
    region               = "us-east-1"
    workspace_key_prefix = "timetracker-web"
  }
}

provider "aws" {
  region = "${var.aws_region}"
}

locals {
  env_name  = "${terraform.workspace}"
  subdomain = "${terraform.workspace == "production" ? "" : "${terraform.workspace}"}"
}

data "aws_ami" "server" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.ami_name}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["${var.ami_publisher}"]
}

data "aws_route53_zone" "main" {
  name = "${var.domain_name}"
}

resource "aws_instance" "server" {
  ami             = "${data.aws_ami.server.id}"
  instance_type   = "${var.server_instance_type}"
  key_name        = "${aws_key_pair.deploy.key_name}"
  security_groups = ["${aws_security_group.server.name}"]

  root_block_device {
    delete_on_termination = "false"
    volume_size           = "${var.server_storage_amount}"
  }

  tags {
    Application = "${var.application_name}"
    Environment = "${local.env_name}"
    Name        = "${var.application_name} ${local.env_name} Web Server"
    Role        = "Web Server"
  }
}

resource "aws_key_pair" "deploy" {
  public_key = "${file(var.public_key)}"
}

resource "aws_security_group" "server" {
  tags {
    Application = "${var.application_name}"
    Environment = "${local.env_name}"
  }
}

resource "aws_security_group_rule" "ssh" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.server.id}"
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "http" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.server.id}"
  to_port           = 80
  type              = "ingress"
}

resource "aws_security_group_rule" "https" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.server.id}"
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "outgoing_http" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.server.id}"
  to_port           = 80
  type              = "egress"
}

resource "aws_security_group_rule" "outgoing_https" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.server.id}"
  to_port           = 443
  type              = "egress"
}

###############################################################################
#                              Generate Passwords                             #
###############################################################################

resource "random_string" "admin_password" {
  length = 32

  keepers {
    instance_id = "${aws_instance.server.id}"
  }
}

resource "random_string" "db_password" {
  length = 32

  keepers {
    instance_id = "${aws_instance.server.id}"
  }
}

resource "random_string" "django_secret_key" {
  length = 50
  special = false

  keepers {
    instance_id = "${aws_instance.server.id}"
  }
}

###############################################################################
#                        Map Web Server to Domain Name                        #
###############################################################################

resource "aws_route53_record" "webserver" {
  name    = "${local.subdomain}"
  records = ["${aws_instance.server.public_ip}"]
  ttl     = "60"
  type    = "A"
  zone_id = "${data.aws_route53_zone.main.id}"
}
