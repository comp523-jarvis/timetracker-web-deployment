output "admin_password" {
    sensitive = true
    value     = "${random_string.admin_password.result}"
}

output "db_password" {
  sensitive = true
  value     = "${random_string.db_password.result}"
}

output "hostname" {
  value = "${aws_route53_record.webserver.fqdn}"
}

output "secret_key" {
  sensitive = true
  value     = "${random_string.django_secret_key.result}"
}
