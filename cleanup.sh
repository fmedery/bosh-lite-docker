#!/bin/bash
set -e
# set -x
. functions

files="bosh-state.json creds.yml cloud-config.yml"

message_warning "$files will deleted from $(pwd)"

read -p "press enter to continue or CTRL+C to cancel."

for file in ${files}
do
  if [ -f ${file} ]
  then
    rm -f ${file}
    message_info "${file} has been deleted"
  fi
done

