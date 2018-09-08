output "db_password" {
  sensitive = true
  value     = "${random_string.db_password.result}"
}

output "secret_key" {
  sensitive = true
  value     = "${random_string.django_secret_key.result}"
}

output "server_ip" {
  value = "${aws_instance.server.public_ip}"
}
