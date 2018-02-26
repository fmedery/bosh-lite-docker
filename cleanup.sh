#!/bin/bash
set -e
# set -x
. functions

files="bosh-state.json creds.yml cloud-config.yml"

message_warning "WARNING this script will delete:

The files $files from $(pwd)
The folder ${HOME}/.bosh
The containers and images use by bosh
The docker network net3
"
read -p "press enter to continue or CTRL+C to cancel."

for file in ${files}
do
  if [ -f ${file} ]
  then
    rm -f ${file}
    message_info "${file} has been deleted"
  fi
done

if [ -d ${HOME}/.bosh ]
then
  rm -rf ${HOME}/.bosh
  message_info "${HOME}/.bosh has been deleted"
fi

for container in $(docker ps -a | grep bosh.io | awk '{print $1}')
do
  docker rm -f ${container}
  message_info "container ${container} has been deleted"
done

for image in $(docker image ls | grep bosh.io | awk '{print $3}')
do 
  docker rmi ${image}
  message_info "${image} has been deleted"  
done

docker network rm net3
message_info "docket network net3 has been deleted"