#!/bin/bash
set -e
#set -x
 
 source ./modules

## get bosh-deployment as a submodule
git submodule init
git submodule update

message_info "check if bosh director is up if not run create.sh to build it"

if ! ping 10.245.0.10 -c 1 -W 1 &>/dev/null
then
  message_warning "bosh director need to be recreated"
  message_warning "starting ./create.sh"
  ./create.sh
else
  message_info "bosh director is up"
fi

export BOSH_ENVIRONMENT="docker"

# default admin user
export BOSH_CLIENT="admin"

# this command will extract the admin password
export BOSH_CLIENT_SECRET=$(bosh int ./creds.yml --path /admin_password)

message_info "create bosh environment alias"
bosh alias-env $BOSH_ENVIRONMENT --environment=10.245.0.10 --ca-cert <(bosh int ./creds.yml --path /director_ssl/ca)


if [ ! -f ./cloud-config.yml ]
then
  message_info "copy docker cloud-config and add dns as a variable"
  cp -f bosh-deployment/docker/cloud-config.yml ./
  sed -i -e 's=\[8.8.8.8\]=((dns))=g' ./cloud-config.yml
fi

## create cloud-config for docker
## we do not really need client and client-secret but because it is a bootstrap for new user I prefer
## to set them in the cli
message_info "apply cloud-config with opsfiles-cloud-config.yml opsfile to add Desjardins DNS"
bosh --non-interactive --environment=$BOSH_ENVIRONMENT --client=${BOSH_CLIENT} --client-secret=${BOSH_CLIENT_SECRET} update-cloud-config cloud-config.yml -o ./opsfiles-cloud-config.yml

message_info "get latest stemcell and upload it"
wget --content-disposition -q -N -P /tmp/ -N https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent 
bosh --non-interactive --environment=$BOSH_ENVIRONMENT --client=${BOSH_CLIENT} --client-secret=${BOSH_CLIENT_SECRET} upload-stemcell /tmp/bosh-stemcell-*-warden-boshlite-ubuntu-trusty-go_agent.tgz


if ! ls -l /var/run/docker.sock|grep srwxrwxrwx -q
then
  message_warning "change permission to docker to 777. sudo will be used"
  sudo chmod 777 /var/run/docker.sock
fi
message_info "setup completed"
echo ""
echo '***********************'
echo "environment   : ${BOSH_ENVIRONMENT} "
echo "client        : ${BOSH_CLIENT}"
echo "client-secret : ${BOSH_CLIENT_SECRET}"

# vim: set ft=bash: