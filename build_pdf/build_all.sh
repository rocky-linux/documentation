#!/bin/bash

# config_files=( 
#   admin_book/en
#   ansible_book/build_ansible_book
#   admin_book/build_admin_book_it
#   bash_book/build_bash_book 
   
#   ansible_book/build_ansible_book_it
#   bash_book/build_bash_book_it
#   ansible_book/build_ansible_book_es
# )
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $SCRIPTPATH

for book in admin_book ansible_book bash_book
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