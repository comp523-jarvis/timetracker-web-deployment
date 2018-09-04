variable "application_name" {
  default     = "ultimanager-api"
  description = "The name of the application."
}

variable "aws_region" {
  default     = "us-east-1"
  description = "The AWS region to provision infrastructure in."
}

variable "ami_name" {
  default     = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
  description = "The name of the AMI to use"
}

variable "ami_publisher" {
  # Default is Canonical's account
  default     = "099720109477"
  description = "The account number of the AMI publisher."
}

variable "public_key" {
  default = "~/.ssh/id_rsa.pub"
  description = "The path to the local file containing the public key for deployment."
}

variable "server_instance_type" {
  default     = "t2.micro"
  description = "The instance type to run the server on."
}

variable "server_storage_amount" {
  default     = "20"
  description = "The storage size of the server drive in gigabytes."
}
