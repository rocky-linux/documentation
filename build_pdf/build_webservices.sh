#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $SCRIPTPATH

for book in web_services

do
  for config_file in $(ls ${SCRIPTPATH}/${book}/*.yml)
  do
    echo "Building $config_file"
    echo "---------------------"
    VERSION=$(date +%Y/%m/%d) mkdocs build -q -f $config_file -d ${SCRIPTPATH}/site/
    echo "" 
  done
done
rm -Rf ${SCRIPTPATH}/site/
