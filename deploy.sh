#!/bin/bash

set -euf
set -o pipefail

usage() {
    echo
    echo "Usage: deploy.sh <deploy-dir> <terraform-workspace>"
    echo
    echo "deploy-dir          - The path to the directory containing the project's"
    ehco "                      deployment configuration."
    echo "terraform-workspace - The name of the Terraform workspace to use."
    echo
}

###################
# Parse Arguments #
###################

if [ -z ${1+x} ]
then
    echo "No deployment directory specified."
    usage

    exit 1
fi

DEPLOY_DIR=$1
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

############################
# Provision Infrastructure #
############################

INFRA_DIR=${DEPLOY_DIR}/terraform/infrastructure
echo "Deploying infrastructure..."
(cd ${INFRA_DIR}; terraform init)
(cd ${INFRA_DIR}; terraform apply -auto-approve)

# Obtain outputs
INFRA_OUTPUTS=$(cd ${INFRA_DIR}; terraform output -json)

ADMIN_PASSWORD=$(echo ${INFRA_OUTPUTS} | jq --raw-output .admin_password.value)
DB_ADDRESS=$(echo ${INFRA_OUTPUTS} | jq --raw-output .db_address.value)
DB_PORT=$(echo ${INFRA_OUTPUTS} | jq --raw-output .db_port.value)
WEB_HOSTNAME=$(echo ${INFRA_OUTPUTS} | jq --raw-output .hostname.value)
SECRET_KEY=$(echo ${INFRA_OUTPUTS} | jq --raw-output .secret_key.value)

echo "Finished provisioning infrastructure."
echo

###############################
# Provision Postgres Database #
###############################

DB_DIR=${DEPLOY_DIR}/terraform/database
echo "Provisioning Postgres database..."
(cd ${DB_DIR}; terraform init)
(cd ${DB_DIR}; terraform apply -auto-approve)

# Obtain outputs
DB_OUTPUTS=$(cd ${DB_DIR}; terraform output -json)

DB_NAME=$(echo ${DB_OUTPUTS} | jq --raw-output .db_name.value)
DB_PASSWORD=$(echo ${DB_OUTPUTS} | jq --raw-output .db_password.value)
DB_USER=$(echo ${DB_OUTPUTS} | jq --raw-output .db_user.value)

echo "Finished provisioning database."
echo

##############################
# Generate Ansible Inventory #
##############################

# Generate a temporary directory to store files in
tmpdir=$(mktemp -d "${TMPDIR:-/tmp/}$(basename $0).XXXXXXXXXXXX")
inventory_file="${tmpdir}/inventory"

cat > ${inventory_file} <<EOF
[webservers]
${WEB_HOSTNAME}
EOF

echo "Generated inventory file:"
echo
cat ${inventory_file}
echo

#####################################
# Configure Webservers with Ansible #
#####################################

(
    cd ${DEPLOY_DIR}/ansible

    ansible-playbook \
        --inventory ${inventory_file} \
        --extra-vars "admin_password='${ADMIN_PASSWORD}'" \
        --extra-vars "db_host='${DB_ADDRESS}'" \
        --extra-vars "db_name='${DB_NAME}'" \
        --extra-vars "db_password='${DB_PASSWORD}'" \
        --extra-vars "db_port='${DB_PORT}'" \
        --extra-vars "db_user='${DB_USER}'" \
        --extra-vars "domain_name='${WEB_HOSTNAME}'" \
        --extra-vars "django_secret_key='${SECRET_KEY}'" \
        deploy.yml
)
