---
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
title: Part 4.2 Database Servers MySQL
---

## MySQL

In this chapter, you will learn how to install MySQL server.

!!! NOTE

    Only notable differences between the MariaDB and MySQL versions are included.

---

**Objectives**: You will learn how to:

:heavy_check_mark: install, configure, and secure the MariaDB server and MySQL server;

:checkered_flag: **RDBMS**, **database**, **MariaDB**, **MySQL**

**Knowledge**: :star: :star: :star:  
**Complexity**: :star: :star: :star:  

**Reading time**: 10 minutes

---

### Installation of MySQL

By default, the installed version of MySQL is version 8.0.

This time, you have to install the `mysql-server` package:

```bash
sudo dnf install mysql-server
```

and start the `mysqld` service:

```bash
sudo systemctl enable mysqld.service --now
```

You can now follow the previous chapter by replacing the following commands:

* `mariadb` => `mysql`
* `mariadb-admin` => `mysql_admin`
* `mariadb-dump` => `mysql_dump`
* `mariadb-secure-installation` => `mysql_secure_installation`

You will have to install a different repository to install the latest version of MySQL server.

Visit this page: https://dev.mysql.com/downloads/repo/yum/ and copy the repository URL.

For example:

```bash
sudo dnf install -y https://dev.mysql.com/get/mysql84-community-release-el9-1.noarch.rpm
```

When completed, you can perform the `dnf update`:

```bash
$ dnf update
Error: This command has to be run with superuser privileges (under the root user on most systems).
[antoine@localhost ~]$ sudo dnf update
MySQL 8.4 LTS Community Server                                                                               377 kB/s | 226 kB     00:00
MySQL Connectors Community                                                                                   110 kB/s |  53 kB     00:00
MySQL Tools 8.4 LTS Community                                                                                170 kB/s |  97 kB     00:00
Dependencies resolved.
============================================================================================================================================= Package                                   Architecture      Version                                Repository   
                       Size
=============================================================================================================================================Installing:
 mysql-community-client                    x86_64            8.4.0-1.el9                            mysql-8.4-lts-community            3.1 M
     replacing  mysql.x86_64 8.0.36-1.el9_3
 mysql-community-server                    x86_64            8.4.0-1.el9                            mysql-8.4-lts-community             50 M
     replacing  mariadb-connector-c-config.noarch 3.2.6-1.el9_0
     replacing  mysql-server.x86_64 8.0.36-1.el9_3
Installing dependencies:
  ...

Transaction Summary
=============================================================================================================================================Install  7 Packages

Total download size: 59 M
Is this ok [y/N]: y
Downloading Packages:
(1/7): mysql-community-client-plugins-8.4.0-1.el9.x86_64.rpm                                                 3.4 MB/s | 1.4 MB     00:00
(2/7): mysql-community-common-8.4.0-1.el9.x86_64.rpm                                                         1.3 MB/s | 576 kB     00:00
(3/7): mysql-community-icu-data-files-8.4.0-1.el9.x86_64.rpm                                                  30 MB/s | 2.3 MB     00:00
(4/7): mysql-community-client-8.4.0-1.el9.x86_64.rpm                                                         5.8 MB/s | 3.1 MB     00:00
(5/7): mysql-community-libs-8.4.0-1.el9.x86_64.rpm                                                           6.8 MB/s | 1.5 MB     00:00
(6/7): net-tools-2.0-0.62.20160912git.el9.x86_64.rpm                                                         1.1 MB/s | 292 kB     00:00
(7/7): mysql-community-server-8.4.0-1.el9.x86_64.rpm                                                          48 MB/s |  50 MB     00:01
---------------------------------------------------------------------------------------------------------------------------------------------Total                                                                                                         30 
MB/s |  59 MB     00:01
MySQL 8.4 LTS Community Server                                                                               3.0 MB/s | 3.1 kB     00:00
Importing GPG key 0xA8D3785C:
 Userid     : "MySQL Release Engineering <mysql-build@oss.oracle.com>"
 Fingerprint: BCA4 3417 C3B4 85DD 128E C6D4 B7B3 B788 A8D3 785C
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-mysql-2023
Is this ok [y/N]: y
Key imported successfully
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :
  ...
Installed:
  mysql-community-server-8.4.0-1.el9.x86_64
  ...

Complete!
```

Do not forget to re-enable and restart your server:

```bash
sudo systemctl enable mysqld.service --now
```

### Check your Knowledge of MySQL

:heavy_check_mark: Which MySQL database version is installed by default?

* [ ] MySQL 5.5
* [ ] MariaDB 10.5
* [ ] MariaDB 11.11
* [ ] Mysql 8
