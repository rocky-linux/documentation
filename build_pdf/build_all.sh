#!/bin/bash

config_files=( 
  build_admin_book
  build_ansible_book
  build_bash_book 
  build_admin_book_it 
  build_ansible_book_it
  build_bash_book_it
  build_ansible_book_es
)

for config_file in "${config_files[@]}"
do
  echo "Building $config_file"
  echo "---------------------"
  mkdocs build -f $config_file.yml
  echo "" 
done
