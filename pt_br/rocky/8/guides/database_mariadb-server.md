# Database mariadb-server

# Prerequisites

* A Rocky Linux server
* Proficiency with a command-line editor (we are using _vi_ in this example)
* A heavy comfort level with issuing commands from the command-line, viewing logs, and other general systems administrator duties
* An understanding of _mariadb-server_ databases is helpful
* All commands are run as the root user or _sudo_

# Introduction

The _mariadb-server_ and it's client _mariadb_ are the open source alternatives to _mysql-server_ and _mysql_, and they share command structure. _mariadb-server_ can be found running on many web servers, due to the popular [Wordpress CMS](https://wordpress.org/) which requires it. This database, though, has many other uses.

If you'd like to use this along with other tools for hardening a web server, refer back to the [Apache Hardened Web Server guide](apache_hardened_webserver.md). 

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

# Conclusions

A database server, such as _mariadb-server_, can be used for many purposes. Because of the popularity of the Wordpress CMS, it is often found on web servers. Before we run the database in production, however, it is a good idea to strengthen its security. 

