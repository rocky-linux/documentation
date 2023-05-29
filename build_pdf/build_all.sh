#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $SCRIPTPATH

for book in admin_book ansible_book bash_book middlewares
do
  for config_file in $(ls ${SCRIPTPATH}/${book}/*.yml)
  do
    echo "Building $config_file"
    echo "---------------------"
    mkdocs build -f $config_file
    echo "" 
  done
  rm -Rf ${SCRIPTPATH}/${book}/site/
done