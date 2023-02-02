#!/usr/bin/env bash
# Change History
# 28/December/2022  Shah A    Initial Modifications for Script and RTF related information


# Retrieve Credentials


read -p 'What is your AWS Access Key ID?' AWSUSERACCESSID
read -sp 'What is your AWS Access Secret Key?' AWSSECRETKEY
read -p 'What is your AWS region?' AWSREGION
read -p 'What is your OCP Cluster name?' CLUSTER_NAME
read -p 'What is your base domain from route53?' BASE_DOMAIN
echo

# set AWS environment variables
/usr/local/bin/aws configure set aws_access_key_id $AWSUSERACCESSID

/usr/local/bin/aws configure set aws_secret_access_key $AWSSECRETKEY

/usr/local/bin/aws configure set default.region $AWSREGION

# Stop immediately if something goes wrong
set -euo pipefail

#Install jq for easier JSON object parsing
brew install jq

# This script will write the terraform.tfvars file into the current working directory.
# The purpose is to populate defaults for subsequent terraform commands.

# Locate the root directory
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

TFVARS_FILE="$ROOT/terraform-openshift4-aws/terraform.tfvars"

if [[ -f "${TFVARS_FILE}" ]]
then
    echo "${TFVARS_FILE} already exists." 1>&2
    echo "Please remove or rename before regenerating." 1>&2
    exit 1;
else
    cat <<EOF > "${TFVARS_FILE}"
cluster_name = "${CLUSTER_NAME}"
base_domain = "${BASE_DOMAIN}"
openshift_pull_secret = "./openshift_pull_secret.json"
openshift_version = "4.10.22"
aws_extra_tags = {
  "owner" = "admin"
  }
aws_region = "${AWSREGION}"
aws_publish_strategy = "External"
EOF
fi

