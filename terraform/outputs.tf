output "db_password" {
  sensitive = true
  value     = "${random_string.db_password.result}"
}

output "server_ip" {
  value = "${aws_instance.server.public_ip}"
}
