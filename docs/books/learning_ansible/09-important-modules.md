---
title: Important Modules
author: Aditya Putta
update: 24-Jul-2023
---


# Ansible Modules 

Ansible modules are reusable pieces of code that can be used to control system resources or execute system commands. Ansible provides a library of modules that can be executed directly on remote hosts or through playbooks. You can also write your own custom modules.

# Commonly used modules 


1. Package management

    The Ansible package management module allows you to install, upgrade, downgrade, remove, and list packages on a system. Here are some examples of how to use the package management module:

    To install the latest version of Apache and MariaDB, you would use the following code:

    ```
    - name: install latest version of Apache and nginx
      dnf:
        name:
        - httpd
        - nginx
        state: latest
    ```
2. File

    The Ansible file module is used to manage files and file properties on remote hosts. It can create, delete, update, and manage the permissions of files. The file module also supports a number of other features, such as creating symlinks, managing file contents, and managing file timestamps.

    To create a file name as ansibletarget.txt and set permissions to 0777

    ```
    - name: Change file ownership, group and permissions
      file:
        path: /etc/ansibletarget.txt
        owner: foo
        group: foo
        mode: '0777'
    ```