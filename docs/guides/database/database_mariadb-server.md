---
title: MariaDB Database Server
author: Steven Spencer
contributors: Ezequiel Bruni, William Perron
tested_with: 8.5, 8.6, 9.0
tags:
  - database
  - mariadb
---

# MariaDB Database Server

## Prerequisites

* A Rocky Linux server
* Proficiency with a command-line editor (we are using _vi_ in this example)
* A heavy comfort level with issuing commands from the command-line, viewing logs, and other general systems administrator duties
* An understanding of _mariadb-server_ databases is helpful
* All commands are run as the root user or _sudo_

## Introduction

The _mariadb-server_ and it's client _mariadb_ are the open source alternatives to _mysql-server_ and _mysql_, and they share command structure. _mariadb-server_ can be found running on many web servers, due to the popular [Wordpress CMS](https://wordpress.org/) which requires it. This database, though, has many other uses.

If you'd like to use this along with other tools for hardening a web server, refer back to the [Apache Hardened Web Server guide](../web/apache_hardened_webserver/index.md).

## Installing mariadb-server

We need to install _mariadb-server_:

`dnf install mariadb-server`

## Securing mariadb-server

To strengthen the security of _mariadb-server_ we need to run a script, but before we do, we need to enable and start mariadb:

`systemctl enable mariadb`

And then:

`systemctl start mariadb`

Next, run this command:

`mysql_secure_installation`

!!! tip

    The version of mariadb-server that comes enabled by default in Rocky Linux 8.5 is 10.3.32. You can install 10.5.13 by enabling the module:

    ```
    dnf module enable mariadb:10.5
    ```

    And then installing `mariadb`. As of version 10.4.6 of MariaDB, MariaDB specific commands are available that you can use instead of the old `mysql` prefixed commands. These include the previously mentioned `mysql_secure_installation` which can now be called with the MariaDB version `mariadb-secure-installation`.

This brings up a dialog:

```
NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user.  If you've just installed MariaDB, and
you haven't set the root password yet, the password will be blank,
so you should just press enter here.

Enter current password for root (enter for none):
```

Since this is a brand new installation, there is no root password set. So just hit enter here.

The next part of the dialog continues:

```
OK, successfully used password, moving on...

Setting the root password ensures that nobody can log into the MariaDB
root user without the proper authorisation.

Set root password? [Y/n]
```

You absolutely _do_ want to have a root password set. You'll want to figure out what this should be and document it in a password manager somewhere so that you can pull it up if necessary. Start by hitting 'Enter' to accept the default "Y". This will bring up the password dialog:

```
New password:
Re-enter new password:
```

Enter your chosen password and then confirm it by entering it again. If this is successful, you will get the following dialog:

```
Password updated successfully!
Reloading privilege tables..
 ... Success!
```

Next the dialog deals with the anonymous user:

```
By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n]
```

The answer here is "Y" so just hit 'Enter' to accept the default.

The dialog proceeds to the section dealing with allowing the root user to login remotely:

```
... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n]
```

root should only be needed locally on the machine. So accept this default as well by hitting 'Enter'.

The dialog then moves on to the 'test' database that is automatically installed with _mariadb-server_:

```
... Success!


By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n]
```

Again, the answer here is the default, so just hit 'Enter' to remove it.

Finally, the dialog ask you if you want to reload the privileges:

```
- Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n]
```

Again, simply hit 'Enter' to do this. If all goes well, you should receive this message:

```
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

MariaDB should now be ready to use.

### Rocky Linux 9.0 Changes

Rocky Linux 9.0 uses `mariadb-server-10.5.13-2` as the default mariadb-server version. As of version 10.4.3, a new plugin is automatically enabled in the server which changes the `mariadb-secure-installation` dialog. That plugin is `unix-socket` authentication. [This article](https://mariadb.com/kb/en/authentication-plugin-unix-socket/) explains the new feature well. Essentially, using `unix-socket` authentication uses the credentials of the logged in user to access the database. It makes it so that if the root user, for example, logs in and then uses `mysqladmin` to create or delete a database (or any other function) that no password is needed for access. Same works with `mysql`. It also means there is no password to compromise remotely. This depends on the security of the users setup on the server for all of the protection of the database.

The second dialog during the `mariadb-secure-installation` after the password is set for the administrative user is:

```
Switch to unix_socket authentication Y/n
```

Obviously, the default here is "Y", but even if you answer "n", with the plugin enabled, no password is requested for the user, at least not from the command line interface. You can specify either password or no password and they both work:

```
mysql

MariaDB [(none)]>
```

```
mysql -p
Enter password:

MariaDB [(none)]>
```

For more information on this feature, refer to the link above. There is a way to switch off this plugin and go back to having the password as a required field, which is also detailed within that link.

## Conclusion

A database server, such as _mariadb-server_, can be used for many purposes. Because of the popularity of the Wordpress CMS, it is often found on web servers. Before we run the database in production, however, it is a good idea to strengthen its security.
