#!/bin/bash

#set -x
set -e

## get submodules
git submodule init
git submodule update

## check if bosh-list is up if not run create.sh
ping 10.245.0.10 -c 1 -W 1 &>/dev/null || ./create.sh

export BOSH_ENVIRONMENT="docker"
# default admin user
export BOSH_CLIENT="admin"
# this command will extract the admin password
export BOSH_CLIENT_SECRET=$(bosh int ./creds.yml --path /admin_password)

bosh alias-env $BOSH_ENVIRONMENT --environment=10.245.0.10 --ca-cert <(bosh int ./creds.yml --path /director_ssl/ca)


## create cloud-config for docker
## we do not really need client and client-secret but because it is a bootstrap for new user I prefer
## to set them in the cli

bosh --environment $BOSH_ENVIRONMENT --client ${BOSH_CLIENT} --client-secret ${BOSH_CLIENT_SECRET} update-cloud-config ./docker-cloud-config.yml -o ./opsfiles-cloud-config.yml

## get latest stemcell
wget --content-disposition -q -N -P /tmp/ -N https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent 


## upload stemcell
bosh --environment $BOSH_ENVIRONMENT --client ${BOSH_CLIENT} --client-secret ${BOSH_CLIENT_SECRET} upload-stemcell /tmp/bosh-stemcell-*-warden-boshlite-ubuntu-trusty-go_agent.tgz

sudo chmod 777 /var/run/docker.sock

echo "admin user name    : $BOSH_CLIENT"
echo "admin user password: $BOSH_CLIENT_SECRET"