---
title: MariaDB Database Server
author: Steven Spencer
contributors: Ezequiel Bruni, William Perron, Ganna Zhyrnova, Joseph Brinkman
tested_with: 8.5, 8.6, 9.0, 9.2, 10.0
tags:
  - database
  - mariadb
---

## Prerequisites

- A Rocky Linux server
- Proficiency with a command-line editor (using *vi* in this example)
- A heavy comfort level with issuing commands from the command-line, viewing logs, and other general systems administrator duties
- An understanding of *mariadb-server* databases is helpful
- Run all commands as root or with *sudo*

## Introduction

The *mariadb-server* and its client *mariadb* are the open source alternatives to *mysql-server* and *mysql*, and they share command structure. *mariadb-server* is running on many web servers, due to the popular [Wordpress CMS](https://wordpress.org/) which requires it. This database, though, has many other uses.

If you want to use this along with other tools for hardening a web server, refer back to the [Apache Hardened Web Server guide](../web/apache_hardened_webserver/index.md).

## Installing `mariadb-server`

You need to install *mariadb-server*:

```bash
dnf install mariadb-server
```

## Securing `mariadb-server`

To strengthen the security of *mariadb-server* you need to run a script, but before you do, you need to enable and start mariadb:

```bash
systemctl enable --now mariadb
```

Next, run this command:

```bash
mysql_secure_installation
```

This brings up a dialog:

```text
NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user. If you've just installed MariaDB, and
haven't set the root password yet, you should just press enter here.

Enter current password for root (enter for none):
```

Since this is a brand-new installation, no root password is set. Just hit ++enter++ here.

The next part of the dialog continues:

```text
Setting the root password or using the unix_socket ensures that nobody
can log into the MariaDB root user without the proper authorisation.

You already have your root account protected, so you can safely answer 'n'.

Switch to unix_socket authentication [Y/n]
```

Answer ++"n"++ and hit ++enter++

```text
You already have your root account protected, so you can safely answer 'n'.

Change the root password? [Y/n]
```

Actually, you have not set a password for the root user **OR** used `unix_socket` authentication, so answer ++"Y"++ here and hit ++enter++.

This will bring up the password dialog:

```text
New password:
Re-enter new password:
```

Enter your chosen password and then confirm it by entering it again. If this is successful, you will get the following dialog:

```text
Password updated successfully!
Reloading privilege tables..
 ... Success!
```

Save this password in a password manager or safe storage location.

Next the dialog deals with the anonymous user:

```text
By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them. This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n]
```

The answer here is "Y" so just hit ++enter++ to accept the default.

The dialog proceeds to the section dealing with allowing the root user to login remotely:

```text
... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n]
```

root should only be needed locally on the machine. So accept this default as well by hitting ++enter++.

The dialog then moves on to the 'test' database that is automatically installed with *mariadb-server*:

```text
... Success!


By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n]
```

Again, the answer here is the default, so just hit ++enter++ to remove it.

Finally, the dialog asks you if you want to reload the privileges:

```text
- Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n]
```

Again, hit ++enter++ to do this. If all goes well, you will receive this message:

```text
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

MariaDB will now be ready to use.

## Conclusion

A database server, such as *mariadb-server*, can be used for many purposes. Because of the popularity of the [Wordpress CMS](https://wordpress.org), it is often found on web servers. Before you run the database in production, however, it is a good idea to strengthen its security.
