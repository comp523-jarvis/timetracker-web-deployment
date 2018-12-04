output "admin_password" {
    sensitive = true
    value     = "${random_string.admin_password.result}"
}

output "db_address" {
  value = "${module.db.db_address}"
}

output "db_admin_password" {
  sensitive = true
  value     = "${module.db.admin_password}"
}

output "db_admin_user" {
  value = "${module.db.admin_username}"
}

output "db_port" {
  value = "${module.db.db_port}"
}

output "hostname" {
  value = "${aws_route53_record.webserver.fqdn}"
}

output "secret_key" {
  sensitive = true
  value     = "${random_string.django_secret_key.result}"
}
