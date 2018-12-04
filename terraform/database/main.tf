terraform {
  backend "s3" {
    bucket               = "ulimi-terraform-state"
    dynamodb_table       = "terraform-lock"
    key                  = "timetracker.tfstate"
    region               = "us-east-1"
    workspace_key_prefix = "timetracker/database"
  }
}

provider "postgresql" {
  host     = "${data.terraform_remote_state.infrastructure.db_address}"
  password = "${data.terraform_remote_state.infrastructure.db_admin_password}"
  port     = "${data.terraform_remote_state.infrastructure.db_port}"
  username = "${data.terraform_remote_state.infrastructure.db_admin_user}"
  version  = "~> 0.1"
}

provider "random" {
  version = "~> 2.0"
}

variable "db_name" {
  default = "timetracker"
  description = "The name of the database to create."
}

variable "db_user" {
  default = "django"
  description = "The name of the database user to create."
}

data "terraform_remote_state" "infrastructure" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config {
    bucket               = "ulimi-terraform-state"
    dynamodb_table       = "terraform-lock"
    key                  = "timetracker.tfstate"
    region               = "us-east-1"
    workspace_key_prefix = "timetracker/infrastructure"
  }
}

resource "postgresql_role" "db_user" {
  login    = true
  name     = "${var.db_user}"
  password = "${random_string.db_password.result}"
}

resource "postgresql_database" "app_db" {
  name = "${var.db_name}"
  owner = "${postgresql_role.db_user.name}"
}

resource "random_string" "db_password" {
  length = 32

  keepers {
    db_host = "${data.terraform_remote_state.infrastructure.db_address}"
  }
}

output "db_name" {
  value = "${postgresql_database.app_db.name}"
}

output "db_password" {
  sensitive = true
  value = "${postgresql_role.db_user.password}"
}

output "db_user" {
  value = "${postgresql_role.db_user.name}"
}
