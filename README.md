# Timetracker Deployment

Deployment configuration for the [`timetracker-web`][timetracker-web] project. We use a combination of [Terraform][terraform] and [Ansible][ansible] during the deployment process. Terraform is used to provision infrastructure on AWS, and Ansible is used to configure servers.

## Deploy Process

*__Note:__ Deployment is only supported from Linux machines. It should work for any distribution, but it has been tested on Ubuntu. It may also work on Mac OS.*

### Prerequisites

Before deploying, there are a few steps that must be performed.

#### Tools

To run the deployment script, you must have the following tools installed and available on your `$PATH`:

* You must have [Ansible installed][ansible-install].
* You must have the [Terraform binary][terraform-releases] accessible. To install it, simply download the latest binary for your architecture, unzip it, and place it in a directory that is on your `$PATH`.
* If using the provided `deploy.sh` script (recommended), you must have [`jq`][jq] installed.

#### Credentials

The only credentials required are an SSH public key (for which you have the corresponding private key) located in `~/.ssh/id_rsa.pub` and AWS credentials. The AWS credentials can be located in [a variety of places][aws-credentials]. The only restriction is they cannot be passed as command line arguments.

### Deploy Script

The `deploy.sh` script in the root of this repository is the recommended (and supported) way to deploy the project.

#### Usage

```
./deploy.sh <deploy-config-dir> <terraform-workspace>
```

##### Arguments

* __`deploy-config-dir`:__ The location of the deployment configuration directory relative to the location that the script is called from. The deployment configuration directory is the root of this repository, ie the directory containing the `ansible` and `terraform` directories.
* __`terraform-workspace`__: The [Terraform workspace][terraform-workspaces] to use.

##### Example Usage

If running the script from the root of the repository and targeting the production environment, the command would be:

```bash
./deploy.sh . production
```

## Advanced Usage and Development

The deployment process is split into two parts: provisioning infrastructure with Terraform and then configuring servers with Ansible.

* Terraform
  * Infrastructure
    * RDS instance
    * Webserver
    * Security groups
  * Database
    * App database user
    * App database
* Ansible
  * Webserver
    * Pull app code, set up Gunicorn and NGINX
    
For more information, see the README files in the [`ansible`](ansible) and [`terraform`](terraform) directories.

## License

This project is licensed under the [MIT License](LICENSE).


[ansible]: https://www.ansible.com/
[ansible-install]: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
[aws-credentials]: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#config-settings-and-precedence
[jq]: https://stedolan.github.io/jq/
[terraform]: https://www.terraform.io
[terraform-releases]: https://www.terraform.io/downloads.html
[terraform-workspaces]: https://www.terraform.io/docs/state/workspaces.html
[timetracker-web]: https://github.com/comp523-jarvis/timetracker-web
