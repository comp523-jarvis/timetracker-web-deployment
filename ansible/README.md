# Ansible Playbook

This directory contains the Ansible playbook used to provision the webserver for the timetracker project.

## Inventory File

To run the playbook, you must pass in an inventory file containing the domain that the webserver is available at. If using the `deploy.sh` script shipped with the repository, this file is generated automatically and looks like:

```ini
[webservers]
ulimi.example.com
```

 ## Variables
 
 The following variables depend on the infrastructure provisioned for the project, and are typically provided by the wrapper script. If calling the playbook on its own, you must provide values for these variables.
 
 ### `admin_password`
 
 The password to use for the admin user that is created on the site. If the site is provisioned from scratch, you can log in with the username `admin` and this password to bootstrap the site.
 
 ### `db_host`
 
 The hostname of the Postgres database to use. This is typically the address of the AWS RDS instance that holds the project's data.
 
 ### `db_name`
 
 The name of the Postgres database to use. This is usually provisioned by Terraform on the RDS instance used.
 
 ### `db_password`
 
 The password to use when connecting to the Postgres database.
 
 ### `db_port`
 
 The port to connect to the Postgres database over.
 
 ### `db_user`
 
 The name of the user to connect to the Postgres database as.
 
 ### `django_secret_key`
 
 The secret key to use for the Django project.
 
 ### `domain_name`
 
 The domain name that the site should be accessible from. This should correspond to the DNS record created to point to the site.
