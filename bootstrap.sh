#!/bin/bash
set -e
# set -x
 
source ./functions

# get bosh-deployment as a submodule
git submodule init
git submodule update

# bosh environment
export BOSH_ENVIRONMENT="docker"

# default bosh admin user
export BOSH_CLIENT="admin"

# if docker socket is not 777 we need change it
if ! ls -l /var/run/docker.sock|grep srwxrwxrwx -q
then
  message_warning "change permission to docker to 777. sudo will be used"
  sudo chmod 777 /var/run/docker.sock
fi

# check if bosh director is up if not run create.sh to build it
if ! ping 10.245.0.10 -c 1 -W 1 &>/dev/null
then
  message_warning "bosh director need to be recreated. Starting ./create.sh"
  ./create.sh
else
  message_info "bosh director is up"
  message_completed
  exit 0
fi

# this command will extract the admin password
export BOSH_CLIENT_SECRET=$(bosh int ./creds.yml --path /admin_password)

message_info "create bosh environment alias"
bosh alias-env ${BOSH_ENVIRONMENT} --environment=10.245.0.10 --ca-cert <(bosh int ./creds.yml --path /director_ssl/ca)

# if cloud-config.yml is missing copy it from the bosh-deployment folder
if [ ! -f ./cloud-config.yml ]
then
  message_info "copy docker cloud-config and add dns as a variable"
  cp -f bosh-deployment/docker/cloud-config.yml ./
fi

# replace hardcoded google dns to a variable so we will be able to overwrite it with a opsfile
sed -i -e 's=\[8.8.8.8\]=((dns))=g' ./cloud-config.yml

# apply cloud-config for docker
message_info "apply cloud-config with opsfiles-cloud-config.yml opsfile to add LAN DNS"
bosh --non-interactive --environment=${BOSH_ENVIRONMENT} --client=${BOSH_CLIENT} --client-secret=${BOSH_CLIENT_SECRET} update-cloud-config cloud-config.yml -o ./opsfiles-cloud-config.yml

# download the latest stemcell and upload it to the director
# we will use /tmp as the target folder
message_info "get latest stemcell and upload it"
wget --content-disposition -q -N -P /tmp/ -N https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent 
bosh --non-interactive --environment=${BOSH_ENVIRONMENT} --client=${BOSH_CLIENT} --client-secret=${BOSH_CLIENT_SECRET} upload-stemcell /tmp/bosh-stemcell-*-warden-boshlite-ubuntu-trusty-go_agent.tgz

message_completed

# vim: set ft=sh:
