#!/bin/bash

set -euf
set -o pipefail

usage() {
    echo
    echo "Usage: deploy.sh <terraform-dir> <terraform-workspace>"
    echo
    echo "terraform-dir       - The path to the directory containing the project's Terraform configuration."
    echo "terraform-workspace - The name of the Terraform workspace to use."
    echo
}

if [ -z ${1+x} ]
then
    echo "No Terraform directory specified."
    usage

    exit 1
fi

TF_DIR=$1
shift

if [ -z ${1+x} ]
then
    echo "No Terraform workspace provided."
    usage

    exit 1
fi

# We export this so any Terraform commands will use the appropriate workspace.
export TF_WORKSPACE=$1
shift

# Obtain deployment parameters from Terraform state.
echo "Initializing Terraform..."
(cd ${TF_DIR}; terraform init >/dev/null)
echo "Done."
echo

echo "Obtaining Terraform outputs..."
SERVER_IP=$(cd ${TF_DIR}; terraform output server_ip)
echo "Done."
echo

echo "Deployment Parameters:"
echo "    Server IP: ${SERVER_IP}"
echo
