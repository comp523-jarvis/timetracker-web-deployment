variable "admin_username" {
  default = "dbadmin"
  description = "The username of the database's admin user."
}

variable "allocated_storage" {
  default = 5
  description = "The amount of storage to allocate to the database (in GB)."
}

variable "app_slug" {
  default = ""
  description = "A slugified version of the application name."
}

variable "backup_days" {
  default = 7
  description = "The number of days to keep database backups for."
}

variable "db_tags" {
  default = {}
  description = "Tags to apply to the database instance."
  type = "map"
}

variable "instance_type" {
  default = "db.t2.micro"
  description = "The type of RDS instance to create."
}

variable "port" {
  default = 5432
  description = "The port that the database is accessible on."
}

variable "sg_tags" {
  default = {}
  description = "The tags to apply to the database security group."
  type = "map"
}


################################################################################
#                                Local Variables                               #
################################################################################

locals {
  app_slug = "${var.app_slug == "" ? "timetracker-${terraform.workspace}" : var.app_slug}"
}


################################################################################
#                                   Resources                                  #
################################################################################

resource "aws_db_instance" "db" {
  allocated_storage = "${var.allocated_storage}"
  allow_major_version_upgrade = false
  auto_minor_version_upgrade = true
  backup_retention_period = "${var.backup_days}"
  copy_tags_to_snapshot = true
  engine = "postgres"
  final_snapshot_identifier = "${local.app_slug}-final"
  identifier_prefix = "${local.app_slug}-"
  instance_class = "${var.instance_type}"
  password = "${random_string.admin_password.result}"
  port = "${var.port}"
  publicly_accessible = true
  tags = "${var.db_tags}"
  username = "${var.admin_username}"
  vpc_security_group_ids = ["${aws_security_group.db.id}"]
}

resource "aws_security_group" "db" {
  name_prefix = "${local.app_slug}-"
  tags = "${var.sg_tags}"
}

resource "aws_security_group_rule" "all" {
  cidr_blocks = ["0.0.0.0/0"]
  from_port = "${aws_db_instance.db.port}"
  protocol = "tcp"
  security_group_id = "${aws_security_group.db.id}"
  to_port = "${aws_db_instance.db.port}"
  type = "ingress"
}

resource "random_string" "admin_password" {
  length = 32
  special = false
}

################################################################################
#                                   Outputs                                    #
################################################################################

output "admin_password" {
  sensitive = true
  value = "${random_string.admin_password.result}"
}

output "admin_username" {
  value = "${var.admin_username}"
}

output "db_address" {
  value = "${aws_db_instance.db.address}"
}

output "db_id" {
  value = "${aws_db_instance.db.id}"
}

output "db_port" {
  value = "${aws_db_instance.db.port}"
}

output "sg_id" {
  value = "${aws_security_group.db.id}"
}
