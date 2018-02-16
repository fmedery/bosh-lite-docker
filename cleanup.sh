#!/bin/bash
set -ex
. functions

files="bosh-state.json creds.yml cloud-config.yml"

if [ $1 == '-d' ] || [ $1 == '--dry-run' ]
then
  message_warning "this is a dry-run"
  COMMAND="echo rm -f"
else
  COMMAND="rm -f"
fi

message_warning "$files will deleted from $(pwd)"

read -p "press enter to continue"

for file in ${files}
do
  if [ -f ${file} ]
  then
    $COMMAND ${file}
    message_info "${file} has been deleted"
  fi
done

