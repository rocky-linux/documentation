#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $SCRIPTPATH

for book in admin_book ansible_book bash_book disa_stig lxd_server middlewares rsync_book sed_awk_grep nvchad_book

do
  for config_file in $(ls ${SCRIPTPATH}/${book}/en.yml)
  do
    echo "Building $config_file"
    echo "---------------------"
    VERSION=$(date +%Y/%m/%d) mkdocs build -q -f $config_file -d ${SCRIPTPATH}/site/
    echo "" 
  done
done
rm -Rf ${SCRIPTPATH}/site/
