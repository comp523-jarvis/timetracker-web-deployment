# Terraform

Our Terraform configuration is split into two parts. The first part, located in the `infrastructure` directory, provisions the EC2 instance(s) for the webserver, an RDS instance, and the associated security groups. The second part, located in the `database` directory, provisions the database and user on the RDS instance from the previous step.

The reason we have to split our configuration into two parts is the case when we are provisioning our infrastructure for the first time. The [`postgresql`][terraform-postgres-provider] provider we use to provision resources within our Postgres database requires information about the database instance to connect to. Because of this, Terraform fails during the "planning" phase since it cannot plan the resources to create in the database without knowing the details of the RDS instance which doesn't exist yet. For more information, see [the issue in the Terraform respository][terraform-partial-apply].


[terraform-partial-apply]: https://github.com/hashicorp/terraform/issues/4149
[terraform-postgres-provider]: https://www.terraform.io/docs/providers/postgresql/index.html
