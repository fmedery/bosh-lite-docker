#!/bin/bash

set -e
# set -x


#sourcing functions file
. functions


if [ -f ./bosh-state.json ]
then
  sed -i -e /current_manifest_sha/d ./bosh-state.json
fi

message_info "create bosh env"
$BOSH create-env bosh-deployment/bosh.yml \
  -o bosh-deployment/docker/cpi.yml \
  -o bosh-deployment/docker/unix-sock.yml \
  -o bosh-deployment/jumpbox-user.yml \
  -o $(pwd)/opsfiles-cloud-config-dns.yml \
  -o $(pwd)/opsfiles-cloud-config-docker.yml \
  --state=bosh-state.json \
  --vars-store creds.yml \
  -v director_name=docker \
  -v internal_cidr=10.245.0.0/16 \
  -v internal_gw=10.245.0.1 \
  -v internal_ip=10.245.0.10 \
  -v docker_host=unix:///var/run/docker.sock \
  -v network=net3

# vim: set ft=sh:
