#!/bin/bash
set -e
set -x

## get bosh-deployment as a submodule
git submodule init
git submodule update

## check if bosh-list is up if not run create.sh to build it
ping 10.245.0.10 -c 1 -W 1 &>/dev/null || ./create.sh

export BOSH_ENVIRONMENT="docker"
# default admin user
export BOSH_CLIENT="admin"
# this command will extract the admin password
export BOSH_CLIENT_SECRET=$(bosh int ./creds.yml --path /admin_password)

bosh alias-env $BOSH_ENVIRONMENT --environment=10.245.0.10 --ca-cert <(bosh int ./creds.yml --path /director_ssl/ca)

## copy docker cloud-config and add dns as variables
cp -f bosh-deployment/docker/cloud-config.yml ./
sed -i -e 's=\[8.8.8.8\]=((dns))=g' ./cloud-config.yml

## create cloud-config for docker
## we do not really need client and client-secret but because it is a bootstrap for new user I prefer
## to set them in the cli

bosh --environment=$BOSH_ENVIRONMENT --client=${BOSH_CLIENT} --client-secret=${BOSH_CLIENT_SECRET} update-cloud-config cloud-config.ymll -o ./opsfiles-cloud-config.yml

## get latest stemcell
wget --content-disposition -q -N -P /tmp/ -N https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent 


## upload stemcell
bosh --environment=$BOSH_ENVIRONMENT --client=${BOSH_CLIENT} --client-secret=${BOSH_CLIENT_SECRET} upload-stemcell /tmp/bosh-stemcell-*-warden-boshlite-ubuntu-trusty-go_agent.tgz

sudo chmod 777 /var/run/docker.sock

echo "client        : ${BOSH_CLIENT}"
echo "client-secret : ${BOSH_CLIENT_SECRET}"