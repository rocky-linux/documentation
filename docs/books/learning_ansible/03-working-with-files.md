---
title: File Management
---

# Ansible - Management of Files

In this chapter you will learn how to manage files with Ansible.

****

**Objectives**: In this chapter you will learn how to:

:heavy_check_mark: modify the content of file;  
:heavy_check_mark: upload files to the targeted servers;  
:heavy_check_mark: retrieve files from the targeted servers.  

:checkered_flag: **ansible**, **module**, **files**  

**Knowledge**: :star: :star:  
**Complexity**: :star:  

**Reading time**: 20 minutes

****

Depending on your needs, you will have to use different Ansible modules to modify the system configuration files.

## `ini_file` module

When you want to modify an INI file (section between `[]` then `key=value` pairs), the easiest way is to use the `ini_file` module.

!!! Note

    More information can be [found here](https://docs.ansible.com/ansible/latest/collections/community/general/ini_file_module.html).

The module requires:

* The value of the section
* The name of the option
* The new value

Example of use:

```bash
- name: change value on inifile
  community.general.ini_file:
    dest: /path/to/file.ini
    section: SECTIONNAME
    option: OPTIONNAME
    value: NEWVALUE
```

## `lineinfile` module

To ensure that a line is present in a file, or when a single line in a file needs to be added or modified, use the `linefile` module.

!!! Note

    More information can be [found here](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html).

In this case, the line to be modified in a file will be found using a regexp.

For example, to ensure that the line starting with `SELINUX=` in the `/etc/selinux/config` file contains the value `enforcing`:

```bash
- ansible.builtin.lineinfile:
    path: /etc/selinux/config
    regexp: '^SELINUX='
    line: 'SELINUX=enforcing'
```

## `copy` module

When a file has to be copied from the Ansible server to one or more hosts, it is better to use the `copy` module.

!!! Note

    More information can be [found here](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html).

Here we are copying `myflile.conf` from one location to another:

```bash
- ansible.builtin.copy:
    src: /data/ansible/sources/myfile.conf
    dest: /etc/myfile.conf
    owner: root
    group: root
    mode: 0644
```

## `fetch` module

When a file has to be copied from a remote server to the local server, it is best to use the `fetch` module.

!!! Note

    More information can be [found here](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/fetch_module.html).

This module does the opposite of the `copy` module:

```bash
- ansible.builtin.fetch:
    src: /etc/myfile.conf
    dest: /data/ansible/backup/myfile-{{ inventory_hostname }}.conf
    flat: yes
```

## `template` module

Ansible and its `template` module use the **Jinja2** template system (<http://jinja.pocoo.org/docs/>) to generate files on target hosts.

!!! Note

    More information can be [found here](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html).

For example:

```bash
- ansible.builtin.template:
    src: /data/ansible/templates/monfichier.j2
    dest: /etc/myfile.conf
    owner: root
    group: root
    mode: 0644
```

It is possible to add a validation step if the targeted service allows it (for example apache with the command `apachectl -t`):

```bash
- template:
    src: /data/ansible/templates/vhost.j2
    dest: /etc/httpd/sites-available/vhost.conf
    owner: root
    group: root
    mode: 0644
    validate: '/usr/sbin/apachectl -t'
```

## `get_url` module

To upload files from a web site or ftp to one or more hosts, use the `get_url` module:

```bash
- get_url:
    url: http://site.com/archive.zip
    dest: /tmp/archive.zip
    mode: 0640
    checksum: sha256:f772bd36185515581aa9a2e4b38fb97940ff28764900ba708e68286121770e9a
```

By providing a checksum of the file, the file will not be re-downloaded if it is already present at the destination location and its checksum matches the value provided.
