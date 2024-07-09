---
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - mariadb
  - mysql
  - database
  - rdbms
title: Part 4. Databases servers
---

MySQL, MariaDB and PostgreSQL are open-source RDBMS (Relational DataBase Management System).

## MariaDB and MySQL

In this chapter, you will learn about the RDBMS MariaDB and MySQL.

****

**Objectives**: In this chapter, you will learn how to:

:heavy_check_mark: install, configure, and secure MariaDB server and MySQL server;
:heavy_check_mark: perform some administrative actions on databases and users.

:checkered_flag: **RDBMS**, **database**, **MariaDB**, **MySQL**

**Knowledge**: :star: :star: :star:
**Complexity**: :star: :star: :star:

**Reading time**: 30 minutes

****

### Generalities

MySQL was developed by Michael "Monty" Widenius (a Finnish computer scientist) who founded MySQL AB in 1995. MySQL AB was acquired by SUN in 2008, which in turn was acquired by Oracle in 2009, which still owns the MySQL software and distributes it under a dual GPL and proprietary license.

In 2009, Michael Widenius left SUN, founded Monty Program AB and launched the development of his community fork of MySQL : MariaDB under GPL license. Governance of the project is entrusted to the MariaDB Foundation, which ensures that the project remains free.

It was not long before the majority of Linux distributions offered MariaDB packages instead of MySQL ones, and major accounts such as Wikipedia and Google also adopted the community fork.

MySQL and MariaDB are among the world's most widely used RDBMSs (professionally and by the general public), particularly for web applications (**LAMP**: Linux + Apache + Mysql-MariaDB + Php).

Mysql-MariaDB's main competitors are:

* PostgreSQL,
* OracleDB,
* Microsoft SQL Server.

Databases services are multi-threaded and multi-user, run on most operating systems (Linux, Unix, BSD, Mac OSx, Windows), and are accessible from many programming languages (Php, Java, Python, C, C++, Perl, others).

Support is offered for several engines, enabling the assignment of different engines to different tables within the same database, depending on requirements:

MyISAM
:   the simplest, but does not support transactions or foreign keys. It is an indexed sequential engine. MyISAM is now deprecated.

InnoDB
:   manages table integrity (foreign keys and transactions), but takes up more disk space. This has been the default engine since MySQL version 5.6. It is a transactional engine.

Memory
:   tables are stored in memory.

Archive
:   data compression on insertion saves disk space, but slows down search queries (cold data).

It is a matter of adopting an engine according to need: Archive for log storage, Memory for temporary data, and so on.

MariaDB/MySQL uses port 3306/tcp for network communication.

As the default version supplied with Rocky is the MariaDB community version of the database, this chapter will deal with this version. Only the differences between MySQL and MariaDB are specifically dealt with.

### Installation

Use the `dnf` command to install the `mariadb-server` package:

```bash
sudo dnf install -y mariadb-server
```

By default, the version installed on a Rocky 9 is 10.5.

Activate the service at startup and start it:

```bash
sudo systemctl enable mariadb --now
```

You can check the status of the `mariadb` service:

```bash
sudo systemctl status mariadb
```

To install a more recent version, you'll need to use the `dnf` modules:

```bash
$ sudo dnf module list mariadb
Last metadata expiration check: 0:00:09 ago on Thu Jun 20 11:39:10 2024.
Rocky Linux 9 - AppStream
Name                          Stream                      Profiles                                        Summary
mariadb                       10.11                       client, galera, server [d]                      MariaDB Module

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

If you have not yet installed the mariadb server, activating the desired module version will suffice:

```bash
$ sudo dnf module enable mariadb:10.11
Last metadata expiration check: 0:02:23 ago on Thu Jun 20 11:39:10 2024.
Dependencies resolved.
============================================================================================================================================= Package                          Architecture                    Version                             Repository                        Size
=============================================================================================================================================
Enabling module streams:
 mariadb                                                          10.11

Transaction Summary
=============================================================================================================================================
Is this ok [y/N]: y
Complete!
```

You can now install the package. The desired version will be automatically installed:

```bash
sudo dnf install -y mariadb-server
```

#### About default users

Please note the logs provided by mariadb at first start (`/var/log/messages`):

```text
mariadb-prepare-db-dir[6560]: Initializing MariaDB database
mariadb-prepare-db-dir[6599]: Two all-privilege accounts were created.
mariadb-prepare-db-dir[6599]: One is root@localhost, it has no password, but you need to
mariadb-prepare-db-dir[6599]: be system 'root' user to connect. Use, for example, sudo mysql
mariadb-prepare-db-dir[6599]: The second is mysql@localhost, it has no password either, but
mariadb-prepare-db-dir[6599]: you need to be the system 'mysql' user to connect.
mariadb-prepare-db-dir[6599]: After connecting you can set the password, if you would need to be
mariadb-prepare-db-dir[6599]: able to connect as any of these users with a password and without sudo
```

### Configuration

Configuration files can are in `/etc/my.cnf` and `/etc/my.cnf.d/`.

Some important default options have been setup in the `/etc/my.cnf.d/mariadb-server.cnf`:

```text
[server]

[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
log-error=/var/log/mariadb/mariadb.log
pid-file=/run/mariadb/mariadb.pid
...
```

As you can see, data is in the `/var/lib/mysql` per default. This folder can require a lot of storage space and recurring volume increases. It is therefore advisable to mount this folder on a dedicated partition.

### Security

MariaDB and Mysql include a script to help you secure your server. It remove for example remote root logins and sample users, the less-secure default options.

Use the `mariadb-secure-installation` and secure your server:

```bash
sudo mariadb-secure-installation
```

The script will prompt you to provide a password for your root user.

!!! NOTE

    The `mysql_secure_installation` command is now a symlink to the `mariadb-secure-installation` command:

    ```bash
    $ ll /usr/bin/mysql_secure_installation
    lrwxrwxrwx. 1 root root 27 Oct 12  2023 /usr/bin/mysql_secure_installation -> mariadb-secure-installation
    ```

If providing a password each time you have to use mariadb's commands is a problem, you can set up a `~/.my.cnf` file with your credentials, that will be used per default by mariadb to connect to your server.

```bash
[client]
user="root"
password="#######"
```

Ensure the permissions are restrictive enough to only allow the current user can access:

```bash
chmod 600 ~/.my.cnf
```

!!! WARNING

    This is not the best way. There is another solution more secure than storing a password in plain text. Since MySQL 5.6.6, it is now possible to store your credentials in an encrypted login `.mylogin.cnf`, thanks to the `mysql_config_editor` command.

If your server runs a firewall (which is a good thing), you might need to consider opening it, but only if you need your service accessible from the outside.

```bash
sudo firewall-cmd --zone=public --add-service=mysql
sudo firewall-cmd --reload
```

!!! NOTE

    The best security is not to open your database server to the outside world (if the application server is hosted on the same server), or to restrict access to authorized IPs only.

### Administration

#### The `mariadb` command

The `mariadb` command is a simple SQL shell that supports interactive and non-interactive use.

```bash
mysql -u user -p [base]
```

| Option    | Information                          |
| --------- | ------------------------------------ |
| `-u user` | Provides a username to connect with. |
| `-p`      | Asks for a password.                 |
| `base`    | The database to connect to.          |

!!! NOTE

    The `mysql` command is now a symlink to the `mariadb` command:

    ```bash
    $ ll /usr/bin/mysql
    lrwxrwxrwx. 1 root root 7 Oct 12  2023 /usr/bin/mysql -> mariadb
    ```

Example:

```bash
$ sudo mariadb -u root
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 15
Server version: 10.5.22-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
+--------------------+
3 rows in set (0.003 sec)
```

#### The `mariadb-admin` command

The `mariadb-admin` command is a client for administering a MariaDB server.

```bash
mariadb-admin -u user -p command
```

| Option    | Information                          |
| --------- | ------------------------------------ |
| `-u user` | Provides a username to connect with. |
| `-p`      | Asks for a password.                 |
| `command` | A command to execute.                |

The `mariadb-admin` provides several commands as `version`, `variables`, `stop-slave` or `start-slaves`, `create databasename`, and so on.

Example:

```bash
mariadb-admin -u root -p version
```

!!! NOTE

    The `mysqladmin` command is now a symlink to the `mariadb-admin` command:

    ```bash
    $ ll /usr/bin/mysqladmin
    lrwxrwxrwx. 1 root root 13 Oct 12  2023 /usr/bin/mysqladmin -> mariadb-admin
    ```

### About logs

MariaDB provides various logs:

* **Error log**: This contains messages generated at service startup and shutdown, as well as important events (warnings and errors).
* **Binary log**: This log (in binary format) records all actions that modify database structure or data. If you need to restore a database, you will need to restore the backup AND replay the binary log to recover the state of the database before the crash.
* **Query log**: All client requests are logged here.
* **Slow requests log**: Slow queries, i.e. those that take longer than a set time to execute, are logged separately in this log. By analyzing this file, you may be able to take steps to reduce execution time (e.g., by setting up indexes or modifying the client application).

With the exception of the binary log, these logs are in text format, so they can be used directly!

To enable logging of long requests, edit the `my.cnf` configuration file to add the following lines:

```bash
slow_query_log      = 1
slow_query_log_file = /var/log/mysql/mysql-slow.log
long_query_time     = 2
```

The minimum value for the `long_query_time` variable is 0 and the default value is `10` seconds.

Restart the service for the changes to take effect.

Once the log file is full, you can analyze it with the `mariadb-dumpslow` command.

```bash
mariadb-dumpslow [options] [log_file ...]
```

| Option         | Information                          |
| -------------- | ------------------------------------ |
| `-t n`         | Displays only the first n queries.   |
| `-s sort_type` | Sorts by number of queries.          |
| `-r`           | Inverts results display.             |

Sort types can be :

| Option      | Information                                                            |
| ----------- | ---------------------------------------------------------------------- |
| `c`         | according to number of requests.                                       |
| `c`         | according to number of requests.                                       |
| `t` or `at` | according to execution time or average execution time (a for average). |
| `l` or `al` | according to lock time or its average.                                 |
| `r` or `aR` | as a function of the number of lines returned or its average.          |

### About backup

As with any RDBMS, backing up a database is done while the data modification is off-line. You can do this by:

* stopping the service, known as an offline backup;
* while the service is running, buy temporarily locking out updates (suspending all modifications). This is an online backup.
* using a snapshot of the LVM file system, enabling the backing up of data with a cold file system.

The backup format can be an ASCII (text) file, representing the state of the database and its data in the form of SQL commands, or a binary file, corresponding to MySQL storage files.

While you can back up a binary file using common utilities such as tar or cpio, an ASCII file requires a utility such as `mariadb-dump`.

The `mariadb-dump` command can perform a dump of your database.

During the process, locking of some data access occurs.

```bash
mariadb-dump -u root -p DATABASE_NAME > backup.sql
```

!!! NOTE

    Do not forget that after restoring a full backup, restoring the binary files (binlogs) completes the reconstitution of the data.

The resulting file is usable to restore the database data. The database must still exist or you must have recreated it beforehand!:

```bash
mariadb -u root -p DATABASE_NAME < backup.sql
```

### Graphical tools

Graphical tools exist to facilitate the administration and management of database data. Here are a few examples:

* [DBeaver](https://dbeaver.io/)

### Workshop

In this workshop, you will install, configure, and secure your mariadb server.

#### Task 1 : Installation

Install the mariadb-server package:

```bash
$ sudo dnf install mariadb-server
Last metadata expiration check: 0:10:05 ago on Thu Jun 20 11:26:03 2024.
Dependencies resolved.
============================================================================================================================================= Package                                       Architecture            Version                              Repository                  Size
=============================================================================================================================================
Installing:
 mariadb-server                                x86_64                  3:10.5.22-1.el9_2                    appstream                  9.6 M
Installing dependencies:
...
```

Installation adds a `mysql` user to the system, with `/var/lib/mysql` as home directory:

```bash
$ cat /etc/passwd
...
mysql:x:27:27:MySQL Server:/var/lib/mysql:/sbin/nologin
...
```

Enable and start the service:

```bash
$ sudo systemctl enable mariadb --now
Created symlink /etc/systemd/system/mysql.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/mysqld.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/multi-user.target.wants/mariadb.service → /usr/lib/systemd/system/mariadb.service.
```

Check the installation:

```bash
$ sudo systemctl status mariadb
● mariadb.service - MariaDB 10.5 database server
     Loaded: loaded (/usr/lib/systemd/system/mariadb.service; enabled; preset: disabled)
     Active: active (running) since Thu 2024-06-20 11:48:56 CEST; 1min 27s ago
       Docs: man:mariadbd(8)
             https://mariadb.com/kb/en/library/systemd/
    Process: 6538 ExecStartPre=/usr/libexec/mariadb-check-socket (code=exited, status=0/SUCCESS)
    Process: 6560 ExecStartPre=/usr/libexec/mariadb-prepare-db-dir mariadb.service (code=exited, status=0/SUCCESS)
    Process: 6658 ExecStartPost=/usr/libexec/mariadb-check-upgrade (code=exited, status=0/SUCCESS)
   Main PID: 6643 (mariadbd)
     Status: "Taking your SQL requests now..."
      Tasks: 9 (limit: 11110)
     Memory: 79.5M
        CPU: 1.606s
     CGroup: /system.slice/mariadb.service
             └─6643 /usr/libexec/mariadbd --basedir=/usr

Jun 20 11:48:56 localhost.localdomain mariadb-prepare-db-dir[6599]: The second is mysql@localhost, it has no password either, but
Jun 20 11:48:56 localhost.localdomain mariadb-prepare-db-dir[6599]: you need to be the system 'mysql' user to connect.
Jun 20 11:48:56 localhost.localdomain mariadb-prepare-db-dir[6599]: After connecting you can set the password, if you would need to be
Jun 20 11:48:56 localhost.localdomain mariadb-prepare-db-dir[6599]: able to connect as any of these users with a password and without sudo
Jun 20 11:48:56 localhost.localdomain mariadb-prepare-db-dir[6599]: See the MariaDB Knowledgebase at https://mariadb.com/kb
Jun 20 11:48:56 localhost.localdomain mariadb-prepare-db-dir[6599]: Please report any problems at https://mariadb.org/jira
Jun 20 11:48:56 localhost.localdomain mariadb-prepare-db-dir[6599]: The latest information about MariaDB is available at https://mariadb.org>Jun 20 11:48:56 localhost.localdomain mariadb-prepare-db-dir[6599]: Consider joining MariaDB's strong and vibrant community:
Jun 20 11:48:56 localhost.localdomain mariadb-prepare-db-dir[6599]: https://mariadb.org/get-involved/
Jun 20 11:48:56 localhost.localdomain systemd[1]: Started MariaDB 10.5 database server.
```

Try connecting to the server:

```bash
$ sudo mariadb
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 9
Server version: 10.5.22-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
+--------------------+
3 rows in set (0.001 sec)

MariaDB [(none)]> exit
Bye
```

```bash
$ sudo mariadb-admin version
mysqladmin  Ver 9.1 Distrib 10.5.22-MariaDB, for Linux on x86_64
Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Server version          10.5.22-MariaDB
Protocol version        10
Connection              Localhost via UNIX socket
UNIX socket             /var/lib/mysql/mysql.sock
Uptime:                 7 min 24 sec

Threads: 1  Questions: 9  Slow queries: 0  Opens: 17  Open tables: 10  Queries per second avg: 0.020
```

As you can see, the `root` user does not need to provide a password. You will correct that during the next task.

#### Task 2 : Secure your server

Launch the `mariadb-secure-installation` and follow the instructions:

```bash
$ sudo mariadb-secure-installation

NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user. If you've just installed MariaDB, and
haven't set the root password yet, you should just press enter here.

Enter current password for root (enter for none):
OK, successfully used password, moving on...

Setting the root password or using the unix_socket ensures that nobody
can log into the MariaDB root user without the proper authorisation.

You already have your root account protected, so you can safely answer 'n'.

Switch to unix_socket authentication [Y/n] y
Enabled successfully!
Reloading privilege tables..
 ... Success!


You already have your root account protected, so you can safely answer 'n'.

Change the root password? [Y/n] y
New password:
Re-enter new password:
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] y
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] y
 ... Success!

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] y
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] y
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

Try connecting again, with and without password to your server:

```bash
$ mariadb -u root
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: NO)

$ mariadb -u root -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 4
Server version: 10.5.22-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]>
```

Configure your firewall:

```bash
sudo firewall-cmd --zone=public --add-service=mysql --permanent
sudo firewall-cmd --reload
```

#### Task 3 : Testing the installation

Verify your installation :

```bash
$ mysqladmin -u root -p version
Enter password:
mysqladmin  Ver 9.1 Distrib 10.5.22-MariaDB, for Linux on x86_64
Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Server version          10.5.22-MariaDB
Protocol version        10
Connection              Localhost via UNIX socket
UNIX socket             /var/lib/mysql/mysql.sock
Uptime:                 29 min 18 sec

Threads: 1  Questions: 35  Slow queries: 0  Opens: 20  Open tables: 13  Queries per second avg: 0.019
```

The `version` give you information about the server.

#### Task 4 : Create a new database and a user

Create a new database:

```sql
MariaDB [(none)]> create database NEW_DATABASE_NAME;
```

Create a new user and give him all rights on all table of that database:

```sql
MariaDB [(none)]> grant all privileges on NEW_DATABASE_NAME.* TO 'NEW_USER_NAME'@'localhost' identified by 'PASSWORD';
```

Replace `localhost` per `%` if you want to grant access from everywhere or replace per IP addresses if you can.

You can restrict the priveleges granted. There are different types of permissions to offer users:

* **SELECT**: read data
* **USAGE**: authorization to connect to the server (given by default when a new user is created)
* **INSERT**: add new tuples to a table.
* **UPDATE**: modify existing tuples
* **DELETE**: delete tuples
* **CREATE**: create new tables or databases
* **DROP**: delete existing tables or databases
* **ALL PRIVILEGES**: all rights
* **GRANT OPTION**: give or remove rights to other users

Do not forget to reload apply the new rights:

```sql
MariaDB [(none)]> flush privileges;
```

Check:

```bash
$ mariadb -u NEW_USER_NAME -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 8
Server version: 10.5.22-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| NEW_DATABASE_NAME  |
| information_schema |
+--------------------+
2 rows in set (0.001 sec)

```

Add sample data into your database:

```bash
$ mariadb -u NEW_USER_NAME -p NEW_DATABASE_NAME
MariaDB [NEW_DATABASE_NAME]> CREATE TABLE users(
    id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    age INT DEFAULT NULL,
    PRIMARY KEY (id));
Query OK, 0 rows affected (0.017 sec)

MariaDB [NEW_DATABASE_NAME]> INSERT INTO users (first_name, last_name, age) VALUES ("Antoine", "Le Morvan", 44);
Query OK, 1 row affected (0.004 sec)
```

#### Task 5 : Create a remote user

In this task, you will create a new user, grant access from remote, and test a connection with that user.

```bash
MariaDB [(none)]> grant all privileges on NEW_DATABASE_NAME.* TO 'NEW_USER_NAME'@'%' identified by 'PASSWORD';
Query OK, 0 rows affected (0.005 sec)

MariaDB [(none)]> flush privileges;
Query OK, 0 rows affected (0.004 sec)
```

Use this user and the `-h` option to connect remotely to your server:

```bash
$ mariadb -h YOUR_SERVER_IP -u NEW_USER_NAME -p NEW_DATABASE_NAME
Enter password:
...

MariaDB [NEW_DATABASE_NAME]>
```

#### Task 6 : Perform an upgrade

Enable the module needed:

```bash
$ sudo dnf module enable mariadb:10.11
[sudo] password for antoine:
Last metadata expiration check: 2:00:16 ago on Thu Jun 20 11:50:27 2024.
Dependencies resolved.
============================================================================================================================================= Package                          Architecture                    Version                             Repository                        Size
=============================================================================================================================================Enabling module streams:
 mariadb                                                          10.11

Transaction Summary
=============================================================================================================================================
Is this ok [y/N]: y
Complete!
```

Upgrade the packages:

```bash
$ sudo dnf update mariadb
Last metadata expiration check: 2:00:28 ago on Thu Jun 20 11:50:27 2024.
Dependencies resolved.
============================================================================================================================================= Package                            Architecture        Version                                                 Repository              Size
=============================================================================================================================================
Upgrading:
 mariadb                            x86_64              3:10.11.6-1.module+el9.4.0+20012+a68bdff7               appstream              1.7 M
 mariadb-backup                     x86_64              3:10.11.6-1.module+el9.4.0+20012+a68bdff7               appstream              6.7 M
 mariadb-common                     x86_64              3:10.11.6-1.module+el9.4.0+20012+a68bdff7               appstream               28 k
 mariadb-errmsg                     x86_64              3:10.11.6-1.module+el9.4.0+20012+a68bdff7               appstream              254 k
 mariadb-gssapi-server              x86_64              3:10.11.6-1.module+el9.4.0+20012+a68bdff7               appstream               15 k
 mariadb-server                     x86_64              3:10.11.6-1.module+el9.4.0+20012+a68bdff7               appstream               10 M
 mariadb-server-utils               x86_64              3:10.11.6-1.module+el9.4.0+20012+a68bdff7               appstream              261 k

Transaction Summary
=============================================================================================================================================
Upgrade  7 Packages

Total download size: 19 M
Is this ok [y/N]: y
Downloading Packages:
(1/7): mariadb-gssapi-server-10.11.6-1.module+el9.4.0+20012+a68bdff7.x86_64.rpm                               99 kB/s |  15 kB     00:00
(2/7): mariadb-server-utils-10.11.6-1.module+el9.4.0+20012+a68bdff7.x86_64.rpm                               1.1 MB/s | 261 kB     00:00
(3/7): mariadb-errmsg-10.11.6-1.module+el9.4.0+20012+a68bdff7.x86_64.rpm                                     2.5 MB/s | 254 kB     00:00
(4/7): mariadb-common-10.11.6-1.module+el9.4.0+20012+a68bdff7.x86_64.rpm                                     797 kB/s |  28 kB     00:00
(5/7): mariadb-10.11.6-1.module+el9.4.0+20012+a68bdff7.x86_64.rpm                                            5.7 MB/s | 1.7 MB     00:00
(6/7): mariadb-server-10.11.6-1.module+el9.4.0+20012+a68bdff7.x86_64.rpm                                     9.5 MB/s |  10 MB     00:01
(7/7): mariadb-backup-10.11.6-1.module+el9.4.0+20012+a68bdff7.x86_64.rpm                                     7.7 MB/s | 6.7 MB     00:00
---------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                         13 MB/s |  19 MB     00:01
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction

...

Complete!
```

Your databases now need upgrading (check your `/var/log/messages` as the service complains):

```text
mariadb-check-upgrade[8832]: The datadir located at /var/lib/mysql needs to be upgraded using 'mariadb-upgrade' tool. This can be done using the following steps:
mariadb-check-upgrade[8832]:  1. Back-up your data before with 'mariadb-upgrade'
mariadb-check-upgrade[8832]:  2. Start the database daemon using 'systemctl start mariadb.service'
mariadb-check-upgrade[8832]:  3. Run 'mariadb-upgrade' with a database user that has sufficient privileges
mariadb-check-upgrade[8832]: Read more about 'mariadb-upgrade' usage at:
mariadb-check-upgrade[8832]: https://mariadb.com/kb/en/mysql_upgrade/
```

Do not forget to execute the upgrade script provided by MariaDB:

```bash
sudo mariadb-upgrade
Major version upgrade detected from 10.5.22-MariaDB to 10.11.6-MariaDB. Check required!
Phase 1/8: Checking and upgrading mysql database
Processing databases
mysql
mysql.column_stats                                 OK
mysql.columns_priv                                 OK
mysql.db                                           OK
...
Phase 2/8: Installing used storage engines... Skipped
Phase 3/8: Running 'mysql_fix_privilege_tables'
Phase 4/8: Fixing views
mysql.user                                         OK
...
Phase 5/8: Fixing table and database names
Phase 6/8: Checking and upgrading tables
Processing databases
NEW_DATABASE_NAME
information_schema
performance_schema
sys
sys.sys_config                                     OK
Phase 7/8: uninstalling plugins
Phase 8/8: Running 'FLUSH PRIVILEGES'
OK
```

#### Task 6 : Perform a dump

The `mariadb-dump` command can perform a dump of your database.

```bash
mariadb-dump -u root -p NEW_DATABASE_NAME > backup.sql
```

Verify:

```bash
cat backup.sql
-- MariaDB dump 10.19  Distrib 10.11.6-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: NEW_DATABASE_NAME
-- ------------------------------------------------------
-- Server version       10.11.6-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
...

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(30) NOT NULL,
  `last_name` varchar(30) NOT NULL,
  `age` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES
(1,'Antoine','Le Morvan',44);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

...
-- Dump completed on 2024-06-20 14:32:41
```

### Check your Knowledge

:heavy_check_mark: Which database version installs by default?

* [ ] MySQL 5.5
* [ ] MariaDB 10.5
* [ ] MariaDB 11.11
* [ ] Mysql 8

:heavy_check_mark: Which command do you use to apply rights changes?

* [ ] flush rights
* [ ] flush privileges
* [ ] mariadb reload
* [ ] apply

### Conclusion

In this chapter, you have installed and secured a MariaDB database server, created a database and a dedicated user.

These skills are a prerequisite for the administration of your databases.

In the next section, you will see how to install the MySQL database instead of the MariaDB fork.

## Mysql

In this chapter, you will learn how to install MySQL server.

Only notable differences between the MariaDB and MySQL versions are included.

****

**Objectives**: In this chapter, you will learn how to:

:heavy_check_mark: install, configure and secure MariaDB server and MySQL server;

:checkered_flag: **RDBMS**, **database**, **MariaDB**, **MySQL**

**Knowledge**: :star: :star: :star:
**Complexity**: :star: :star: :star:

**Reading time**: 10 minutes

****

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

You can now follow the previous chapter replacing the following commands:

* `mariadb` => `mysql`
* `mariadb-admin` => `mysql_admin`
* `mariadb-dump` => `mysql_dump`
* `mariadb-secure-installation` => `mysql_secure_installation`

To install the latest version of mysql-server, you will have to install a different repository.

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
============================================================================================================================================= Package                                   Architecture      Version                                Repository                          Size
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
---------------------------------------------------------------------------------------------------------------------------------------------Total                                                                                                         30 MB/s |  59 MB     00:01
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

### Check your Knowledge MySQL

:heavy_check_mark: Which MySQL database version is installed by default?

* [ ] MySQL 5.5
* [ ] MariaDB 10.5
* [ ] MariaDB 11.11
* [ ] Mysql 8

## Secondary server with MariaDB

In this chapter, you will learn how to configure a Primary/Secondary system servers with MariaDB.

****

**Objectives**: In this chapter, you will learn how to:

:heavy_check_mark: activate the binlogs in your servers;
:heavy_check_mark: setup a secondary server to replicate data from primary server.

:checkered_flag: **MariaDB**, **Replication**, **Primary**, **Secondary**

**Knowledge**: :star: :star:
**Complexity**: :star: :star: :star:

**Reading time**: 10 minutes

****

### Generalities secondary server with MariaDB

As soon as you start using your database more intensively, you will need to replicate your data on several servers.

This can be done in several ways:

* Distribute write requests to the primary server and read requests to the secondary server.
* Perform database backups on the secondary server, which avoids blocking writes to the primary server for the duration of the backups.

If your usage becomes even more demanding, you may consider switching to a primary/primary system: replications are then made crosswise, but beware of the risk of blocking the uniqueness of primary keys. Otherwise, you will need to switch to a more advanced clustering system.

### Configuration secondary server with MariaDB

#### How to activate the binlogs

Perform this action on the primary and secondary servers:

Add the following options to your `/etc/my.cnf.d/mariadb-server.cnf` file, under the `[mariadb]` key:

```file
[mariadb]
log-bin
server_id=1
log-basename=server1
binlog-format=mixed
```

for the primary server, and for the secondary server:

```file
[mariadb]
log-bin
server_id=2
log-basename=server2
binlog-format=mixed
```

The `server_id` option must be unique on each server in the cluster, while the `log-basename` option allows you to specify a prefix to the binlog files. If you do not do this, you will not be able to rename your server in the future.

You can now restart the mariadb service on both servers:

```bash
sudo systemctl restart mariadb
```

You can check that binlogs files are well created:

```bash
$ ll /var/lib/mysql/
total 123332
...
-rw-rw----. 1 mysql mysql         0 Jun 21 11:07 multi-master.info
drwx------. 2 mysql mysql      4096 Jun 21 11:07 mysql
srwxrwxrwx. 1 mysql mysql         0 Jun 21 11:16 mysql.sock
-rw-rw----. 1 mysql mysql       330 Jun 21 11:16 server1-bin.000001
-rw-rw----. 1 mysql mysql        21 Jun 21 11:16 server1-bin.index
...
```

#### How to configure the replication

First of all, on the primary, you will need to create users authorized to replicate data (be careful to restrict the IPs authorized):

```bash
$ sudo mariadb

MariaDB [(none)]> CREATE USER 'replication'@'%' IDENTIFIED BY 'PASSWORD';
Query OK, 0 rows affected (0.002 sec)

MariaDB [(none)]> GRANT REPLICATION SLAVE ON *.* TO 'replication'@'%';
Query OK, 0 rows affected (0.002 sec)
```

or better for security (change '192.168.1.101' with your own secondary IP):

```bash
$ sudo mariadb

MariaDB [(none)]> CREATE USER 'replication'@'192.168.1.101' IDENTIFIED BY 'PASSWORD';
Query OK, 0 rows affected (0.002 sec)

MariaDB [(none)]> GRANT REPLICATION SLAVE ON *.* TO 'replication'@'192.168.1.101';
Query OK, 0 rows affected (0.002 sec)
```

If your primary server already contains data, you will need to lock new transactions while the exporting or importing of data occurs to the secondary server(s), and tell the secondary servers when to start replication. If your server does not yet contain any data, the procedure is greatly simplified.

Prevent any changes to the data while you view the binary log position:

```bash
$ sudo mariadb

MariaDB [(none)]> FLUSH TABLES WITH READ LOCK;
Query OK, 0 rows affected (0.021 sec)

MariaDB [(none)]> SHOW MASTER STATUS;
+--------------------+----------+--------------+------------------+
| File               | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+--------------------+----------+--------------+------------------+
| server1-bin.000001 |     1009 |              |                  |
+--------------------+----------+--------------+------------------+
1 row in set (0.000 sec)

```

Do not quit your session to keep the lock.

Record the File and Position details.

If your server contains data, it is time to create a backup and import it onto your secondary server(s). Keep the lock for the duration of the backup, and release it as soon as the backup is complete. This reduces downtime (the time it takes to copy and import the data on the secondary servers).

You can remove the lock now:

```bash
$ sudo mariadb

MariaDB [(none)]> UNLOCK TABLES;
Query OK, 0 rows affected (0.000 sec)
```

On the secondary server, you can now ready to setup the primary server to replicate with:

```bash
MariaDB [(none)]> CHANGE MASTER TO
  MASTER_HOST='192.168.1.100',
  MASTER_USER='replication',
  MASTER_PASSWORD='PASSWORD',
  MASTER_PORT=3306,
  MASTER_LOG_FILE='server1-bin.000001',
  MASTER_LOG_POS=1009,
  MASTER_CONNECT_RETRY=10;
Query OK, 0 rows affected, 1 warning (0.021 sec)

MariaDB [(none)]> START SLAVE;
Query OK, 0 rows affected (0.001 sec)
```

Replace the primary server IP with yours and the `MASTER_LOG_FILE` and `MASTER_LOG_POS` values with those you previously registered.

Check if the replication is ok:

```bash
MariaDB [(none)]> SHOW SLAVE STATUS \G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.1.100
                   Master_User: replication
               Master_Log_File: server1-bin.000001
           Read_Master_Log_Pos: 1009
...
         Seconds_Behind_Master: 0
       Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
...
1 row in set (0.001 sec)
```

The `Seconds_Behind_Master` is an interesting value to monitor as it can help you see if there is a replication issue.

### Workshop secondary server using MariaDB

For this workshop, you will need two servers with MariaDB services installed, configured and secured as described in the previous chapters.

You will configure replication on the secondary server, then create a new database, insert data into it and check that the data is accessible on the secondary server.

Our two servers have the following IP addresses:

* server1: 192.168.1.100
* server2: 192.168.1.101

Remember to replace these values with your own.

#### Task 1: Create a dedicated replication user

On the primary server:

```bash
$ sudo mariadb

MariaDB [(none)]> CREATE USER 'replication'@'192.168.1.101' IDENTIFIED BY 'PASSWORD';
Query OK, 0 rows affected (0.002 sec)

MariaDB [(none)]> GRANT REPLICATION SLAVE ON *.* TO 'replication'@'192.168.1.101';
Query OK, 0 rows affected (0.002 sec)
```

#### Task 2: Record the primary server values

```bash
$ sudo mariadb

MariaDB [(none)]> FLUSH TABLES WITH READ LOCK;
Query OK, 0 rows affected (0.021 sec)

MariaDB [(none)]> SHOW MASTER STATUS;
+--------------------+----------+--------------+------------------+
| File               | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+--------------------+----------+--------------+------------------+
| server1-bin.000001 |     1009 |              |                  |
+--------------------+----------+--------------+------------------+
1 row in set (0.000 sec)

MariaDB [(none)]> UNLOCK TABLES;
Query OK, 0 rows affected (0.000 sec)
```

#### Task 3: Activate the replication

On the secondary server:

```bash
MariaDB [(none)]> CHANGE MASTER TO
  MASTER_HOST='192.168.1.100',
  MASTER_USER='replication',
  MASTER_PASSWORD='PASSWORD',
  MASTER_PORT=3306,
  MASTER_LOG_FILE='server1-bin.000001',
  MASTER_LOG_POS=1009,
  MASTER_CONNECT_RETRY=10;
Query OK, 0 rows affected, 1 warning (0.021 sec)

MariaDB [(none)]> START SLAVE;
Query OK, 0 rows affected (0.001 sec)
```

Check if the replication is ok:

```bash
MariaDB [(none)]> SHOW SLAVE STATUS \G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.1.100
                   Master_User: replication
               Master_Log_File: server1-bin.000001
           Read_Master_Log_Pos: 1009
...
         Seconds_Behind_Master: 0
       Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
...
1 row in set (0.001 sec)
```

#### Task 4: Create a new database and a user

On the primary:

```bash
MariaDB [(none)]> create database NEW_DATABASE_NAME;
Query OK, 1 row affected (0.002 sec)

MariaDB [(none)]> grant all privileges on NEW_DATABASE_NAME.* TO 'NEW_USER_NAME'@'localhost' identified by 'PASSWORD';
Query OK, 0 rows affected (0.004 sec)
```

On the secondary, check for creation of the database:

```bash
MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| NEW_DATABASE_NAME  |
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
```

Magic !

On the secondary, try connecting the new user created on the primary:

```bash
$ mariadb -u NEW_USER_NAME -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.

MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| NEW_DATABASE_NAME  |
| information_schema |
+--------------------+
2 rows in set (0.000 sec)
```

#### Task 5: Insert new data

Insert new data on the primary server:

```bash
MariaDB [(none)]> use NEW_DATABASE_NAME
Database changed

MariaDB [(none)]>  CREATE TABLE users(
    ->     id INT NOT NULL AUTO_INCREMENT,
    ->     first_name VARCHAR(30) NOT NULL,
    ->     last_name VARCHAR(30) NOT NULL,
    ->     age INT DEFAULT NULL,
    ->     PRIMARY KEY (id));

MariaDB [NEW_DATABASE_NAME]> INSERT INTO users (first_name, last_name, age) VALUES ("Antoine", "Le Morvan", 44);
Query OK, 1 row affected (0.004 sec)

```

On the secondary, check that data are replicated:

```bash
MariaDB [(none)]> use NEW_DATABASE_NAME
Database changed

MariaDB [NEW_DATABASE_NAME]> show tables;
+-----------------------------+
| Tables_in_NEW_DATABASE_NAME |
+-----------------------------+
| users                       |
+-----------------------------+
1 row in set (0.000 sec)

MariaDB [NEW_DATABASE_NAME]> SELECT * FROM users;
+----+------------+-----------+------+
| id | first_name | last_name | age  |
+----+------------+-----------+------+
|  1 | Antoine    | Le Morvan |   44 |
+----+------------+-----------+------+
1 row in set (0.000 sec)
```

### Check your Knowledge secondary server with MariaDB

:heavy_check_mark: Each server must have the same id within a cluster?

* [ ] True
* [ ] False

:heavy_check_mark: Binary logs must be enabled before replication is activated.?

* [ ] True
* [ ] False
* [ ] It depends

### Conclusion secondary server with MariaDB

As you can see, creating one or more secondary servers is a relatively easy action, but it does require service interruption on the main server.

It does, however, offer many advantages: high data availability, load balancing, and simplified backup.

It goes without saying that, in the event of a main server crash, promotion of one of the secondary servers to main server can occur.

<!---

## PostgreSQL

In this chapter, you will learn about XXXXXXX.

****

**Objectives**: In this chapter, you will learn how to:

:heavy_check_mark: XXX
:heavy_check_mark: XXX

:checkered_flag: **XXX**, **XXX**

**Knowledge**: :star:
**Complexity**: :star:

**Reading time**: XX minutes

****

### Generalities

### Configuration

### Security

### Workshop

#### Task 1 : XXX

#### Task 2 : XXX

#### Task 3 : XXX

#### Task 4 : XXX

### Check your Knowledge

:heavy_check_mark: Simple question? (3 answers)

:heavy_check_mark: Question with multiple answers?

* [ ] Answer 1
* [ ] Answer 2
* [ ] Answer 3
* [ ] Answer 4

-->
