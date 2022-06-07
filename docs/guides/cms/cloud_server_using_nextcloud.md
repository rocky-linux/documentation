---
title: Cloud Server Using Nextcloud
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.5, 8.6
tags:
  - cloud
  - nextcloud
---

# Cloud Server Using Nextcloud

## Prerequisites And Assumptions

* Server running Rocky Linux (you can install Nextcloud on any Linux distribution, but this procedure will assume you're using Rocky).
* A high degree of comfort operating from the command line for installation and for configuration.
* Knowledge of a command-line editor. For this example, we are using _vi_, but you can use your favorite editor if you have one.
* While Nextcloud can be installed via a snap application, we will be documenting two installation methods, the module and the .zip file.
* We will be applying concepts from the Apache "sites enabled" document (linked to down below) for directory setup in the .zip file method.
* We will also be using the _mariadb-server_ hardening procedure (also linked to later) for database setup.
* Throughout this document we will assume that you are root, or that you can be by using _sudo_.
* We are using an example domain of "yourdomain.com" in the .zip file method.

## Introduction

If you are in charge of a server environment for a large (or even a small) company, you may be tempted by cloud applications. Doing things in the cloud can free up your own resources for other things, but there is a downside to this, and that is the loss of control of your company's data. If the cloud application is compromised, so too may be your company's data.

Taking the cloud back into your own environment is a way to reclaim security of your data at the expense of your time and energy. Sometimes, that is a cost worth paying.

Nextcloud offers an open source cloud with security and flexibility in mind. Note that building a Nextcloud server is a good exercise, even if you opt to take your cloud off-site in the end. The following procedure deals with setting up Nextcloud on Rocky Linux.

## Common Procedures Needed In For Both Installations

There are several steps here that are the same regardless of which install method you are using. These are installing the EPEL and Remi repositories, configuring PHP, and setting up mariadb. I will link back to these procedures within the .zip file installation method (second method). Just be aware of this.

## Nextcloud - Module Method

Why use the Nextcloud module?  After enabling the module we can then install Nextcloud, which will download nearly all of the dependencies for you. You will still have to install your database of choice (mariadb, postgresql, or sqlite) but your web platform will be handled by the Nextcloud packages, as well as any back-end scripts. The downside to this particular method is that you lose control over where you want Nextcloud to install.

When operating a bunch of servers or containers with web applications on them, a Systems Administrator would prefer to look for things in the same spot, not try to keep up with where package 'A' installed itself as opposed to package 'B'.

### Installing And Configuring Repositories and Modules
<a name="repositories"></a>

For this installation, we will require two repositories. We need to install the EPEL (Extra Packages for Enterprise Linux), and the Remi Repository for PHP 8.0 (a minimum of version 7.3 or 7.4 is required and the Rocky Linux version of 7.4 (not enabled by default) does not contain all of the packages that Nextcloud needs. We are going to use PHP 8.0 from the Remi repository instead.

To install the EPEL run:

`dnf install epel-release`

To install the Remi repository run:

`dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm`

Then run `dnf update` again.

Run the following to see a list of php modules that can be enabled:

`dnf module list php`

```
Rocky Linux 8 - AppStream
Name                    Stream                     Profiles                                     Summary                                 
php                     7.2 [d]                    common [d], devel, minimal                   PHP scripting language                  
php                     7.3                        common [d], devel, minimal                   PHP scripting language                  
php                     7.4                        common [d], devel, minimal                   PHP scripting language               
php                     7.4                        common [d], devel, minimal                   PHP scripting language                  
Remi's Modular repository for Enterprise Linux 8 - x86_64
Name                    Stream                     Profiles                                     Summary                                 
php                     remi-7.2                   common [d], devel, minimal                   PHP scripting language                  
php                     remi-7.3                   common [d], devel, minimal                   PHP scripting language                  
php                     remi-7.4                   common [d], devel, minimal                   PHP scripting language                  
php                     remi-8.0                   common [d], devel, minimal                   PHP scripting language                  
php                     remi-8.1                   common [d], devel, minimal                   PHP scripting language                  
Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

We want to grab the newest PHP that Nextcloud is compatible with, which at this moment is 8.0, so we will enable that module by doing:

`dnf module enable php:remi-8.0`

To see how this changes the output of the module list, run the module list command again and you will see the "[e]" next to 8.0:

`dnf module list php`

And the output again is the same except for this line:

`php                    remi-8.0 [e]                   common [d], devel, minimal                  PHP scripting language`

The final step is to enable the stable version of Nextcloud from the modules. This is as easy as:

`dnf module enable nextcloud:nextcloud-stable`

### Installing Packages

To see what enabling the Nextcloud module will offer for you to install, do the following:

`dnf list available | grep nextcloud` which will show you output like this:

```
nextcloud.noarch                                                  22.0.0-2.module_el8+12398+2facbd17                epel-modular
nextcloud-client.x86_64                                           3.2.4-2.el8                                       epel        
nextcloud-client-devel.x86_64                                     3.2.4-2.el8                                       epel        
nextcloud-client-dolphin.x86_64                                   3.2.4-2.el8                                       epel        
nextcloud-client-libs.x86_64                                      3.2.4-2.el8                                       epel        
nextcloud-client-nautilus.x86_64                                  3.2.4-2.el8                                       epel        
nextcloud-httpd.noarch                                            22.0.0-2.module_el8+12398+2facbd17                epel-modular
nextcloud-mysql.noarch                                            22.0.0-2.module_el8+12398+2facbd17                epel-modular
nextcloud-nginx.noarch                                            22.0.0-2.module_el8+12398+2facbd17                epel-modular
nextcloud-postgresql.noarch                                       22.0.0-2.module_el8+12398+2facbd17                epel-modular
nextcloud-sqlite.noarch                                           22.0.0-2.module_el8+12398+2facbd17                epel-modular
```
Our example here uses Apache and mariadb, so to install what we need, we simply need to do the following:

`dnf install nextcloud nextcloud-httpd nextcloud-mysql mariadb-server`

### Configuring

#### Configuring Apache

Set _apache_ to start on boot:

`systemctl enable httpd`

Then start it:

`systemctl start httpd`

When you install Nextcloud using the module, the configuration is created for you. In fact, there are multiple configurations. You can find these by looking in conf.d directory like this: `ls -al /etc/httpd/conf.d` which should show you output similar to this:

```
-rw-r--r--. 1 root root  400 Nov 15 03:13 README
-rw-r--r--. 1 root root 2926 Nov 15 03:13 autoindex.conf
-rw-r--r--. 1 root root  994 Jul 14  2021 nextcloud-access.conf.avail
-rw-r--r--. 1 root root  278 Jul 14  2021 nextcloud-auth-any.inc
-rw-r--r--. 1 root root  313 Jul 14  2021 nextcloud-auth-local.inc
-rw-r--r--. 1 root root  263 Jul 14  2021 nextcloud-auth-none.inc
-rw-r--r--. 1 root root 2407 Jul 14  2021 nextcloud-defaults.inc
-rw-r--r--. 1 root root 1893 Jul 14  2021 nextcloud.conf
-rw-r--r--. 1 root root 1668 Dec 16 06:57 php.conf
-rw-r--r--. 1 root root 1252 Nov 15 03:10 userdir.conf
-rw-r--r--. 1 root root  574 Nov 15 03:10 welcome.conf
```
The primary configuration here for Nextcloud is `nextcloud.conf`, but you should review the rest of these files. There are instructions on how to use them at the top of each file. In our lab installation, the localhost is not available from any web interface. If you look at the top of the `nextcloud-access.conf.avail` you will see a warning to enable this only after the admin account and initial installation have been complete. Since this is not possible in the lab instance, we are doing this early:

`ln -s /etc/httpd/conf.d/nextcloud-access.conf.avail /etc/httpd/conf.d/z-nextcloud-access.conf`

We also need a special empty file so that we can install Nextcloud. This file resides in `/etc/nextcloud` and is called CAN_INSTALL. To create it, simply do the following:

`touch /etc/nextcloud/CAN_INSTALL`

#### Configuring PHP
<a name="confphp"></a>

We need to set the timezone for PHP. To do this, open up php.ini with your text editor of choice:

`vi /etc/php.ini`

Then find the line:

`;date.timezone =`

We need to remove the remark (;) and set our timezone. For our example timezone, we would put in either:

`date.timezone = "America/Chicago"`

OR

`date.timezone = "US/Central"`

Then save an exit the php.ini file.

Note that for the sake of keeping things the same, your timezone in the _php.ini_ file should match up to your machine's timezone setting. You can find out what this is set to by doing the following:

`ls -al /etc/localtime`

Which should show you something like this, assuming you set your timezone when you installed Rocky Linux and are living in the Central time zone:

`/etc/localtime -> /usr/share/zoneinfo/America/Chicago`

#### Configuring mariadb-server
<a name="mariadbproc"></a>

Set _mariadb-server_ to start on boot:

`systemctl enable mariadb`

And then start it:

`systemctl restart mariadb`

Again, as indicated earlier, we will be using the setup procedure for hardening _mariadb-server_ found [here](../database/database_mariadb-server.md) for the initial configuration.

#### Configuring Nextcloud

Now comes the fun! First, make sure that you have your services running. If you followed the above steps, they should already be running. We have had several steps between those initial service starts, so let's go ahead and restart them, just to be sure:

```
systemctl restart httpd
systemctl restart mariadb
```

If everything restarts and there are no issues, then you are ready to move on.

To do the initial configuration, we want to actually load the site in a web browser. In our lab instance, we've got no hostname set up, so we are going to the site by IP address like this:

`http://192.168.1.108/nextcloud`

Assuming that you've done everything correctly so far, you should be presented with a Nextcloud setup screen:

![nextcloud login screen](../images/nextcloud_screen.jpg)

There are a couple of things that we want to do differently than the defaults that show up:

* At the top of the web page, where it says "Create an admin account", set the user and password. For the sake of this document, we are entering "admin" and setting a strong password. Remember to save this somewhere safe (like a password manager) so that you don't lose it! Even though you have typed into this field, don't hit 'Enter' until we have done all of the setup fields!
* Under the "Configure the database" section, change from "SQLite" to "MySQL/MariaDB" by clicking on that button.
* Type the MariaDB root user and password that you set earlier into the "Database user" and "Database password" fields
* In the "Database name" field, type "nextcloud"
* In the "localhost" field, type "localhost:3306" (3306 is the default _mariadb_ connect port)

Once you have all this, click `Finish Setup` and you should be up and running.

### Notes for the Systems Administrator

As noted earlier, if using the module install for Nextcloud, Nextcloud is going to put things where it thinks they should be, not where the Systems Administrator might go looking for them. For this reason, as part of the setup steps, I recommend that a README.txt file be created in each location where the Systems Administrator would logically look.

I came from an environment where we used `/etc/httpd/sites-enabled` for configuration files (see the alternate install steps for more) and put our web files in `/var/www/sub-domains/[site_name]/html`. If I were to use the module install of Nextcloud, then, I would want to put a README.txt file in both locations.

The README.txt file in `/etc/httpd/sites-enabled/` might contain:

```
Nextcloud was installed using the module. You can find the configuration in /etc/httpd/conf.d/nextcloud.conf
```

While the README.txt file in `/var/www/sub-domains/[site_name]/html` might contain:

```
Nextcloud was installed using the module. You can find the web files in /usr/share/nextcloud
```
## Nextcloud .zip Install

If the module install is so easy, why consider using the .zip file install method? The reason is environment control. As noted in the Nextcloud module install procedure, Nextcloud chooses where to put the web files, where to put the configuration files, and most of the remaining setup options. Using the .zip file install method is definitely more intensive than the module install method, but it *does* give the Systems Administrator more control over where things will end up.

### Installing And Configuring Repositories (same procedure)

This is done exactly the same way as the with the [module install procedure](#repositories).

### Installing Packages

We need a lot of packages installed. Some of these may already be installed with your default Rocky Linux installation, but make sure by running the following command the following:

`dnf install httpd mariadb-server vim wget zip unzip libxml2 openssl php80-php php80-php-ctype php80-php-curl php80-php-gd php80-php-iconv php80-php-json php80-php-libxml php80-php-mbstring php80-php-openssl php80-php-posix php80-php-session php80-php-xml php80-php-zip php80-php-zlib php80-php-pdo php80-php-mysqlnd php80-php-intl php80-php-bcmath php80-php-gmp`

### Configuring Packages And Directories

#### Configuring apache

Set _apache_ to start on boot:

`systemctl enable httpd`

As noted earlier, we are using the "Apache Sites Enabled" procedure found [here](../web/apache-sites-enabled.md) to configure Apache. Follow that guide to get the configuration directories setup and the _httpd.conf_ file modified and then return to this document for the remaining steps.

#### Create The Configuration

For Nextcloud, we will need to create the following configuration file.

`vi /etc/httpd/sites-available/com.yourdomain.nextcloud`

Your configuration file should look something like this:

```
<VirtualHost *:80>
  DocumentRoot /var/www/sub-domains/com.yourdomain.nextcloud/html/
  ServerName  nextcloud.yourdomain.com
  <Directory /var/www/sub-domains/com.yourdomain.nextcloud/html/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>
```

Once done, save your changes (with `SHIFT:wq!` for _vi_).

Next, create a link to this file in /etc/httpd/sites-enabled:

`ln -s /etc/httpd/sites-available/com.yourdomain.nextcloud /etc/httpd/sites-enabled/`

#### Creating The Directory

As noted in the configuration above, the _DocumentRoot_ needs to be created. This can be done by:

`mkdir -p /var/www/sub-domains/com.yourdomain.com/html`

This is where our Nextcloud instance will be installed.

#### Configure PHP (same procedure)

This is done exactly like the [module install procedure](#confphp).

#### Configure Mariadb (same procedure)

This is done exactly like the [module install procedure](#mariadbproc).

### Installing Nextcloud

This install method for Nextcloud uses the server install .zip file.

#### Get The Nextcloud .zip File And Unzip

The next few steps assume that you are remotely connected to your Nextcloud server via _ssh_ with a remote console open:

* Navigate to the [Nextcloud web site](https://nextcloud.com/)
* Let your mouse hover over "Get Nextcloud" which will bring up a drop down menu.
* Click on "Server Packages".
* Right-click on "Download Nextcloud" and copy the link address. (the exact syntax of this is different browser to browser)
* In your remote console on the Nextcloud server, type "wget" and then a space and paste in what you just copied. You should get something like the following: `wget https://download.nextcloud.com/server/releases/nextcloud-21.0.1.zip`
* Once you hit enter, the download of the .zip file will start and will be completed fairly quickly.

Once the download is complete, unzip the Nextcloud zip file by using the following:

`unzip nextcloud-21.0.1.zip`

### Copying Content And Changing Permissions

After completing the unzip step, you should now have a new directory in /root called "nextcloud." Change into this directory:

`cd nextcloud`

And either copy or move the content to our _DocumentRoot_:

`cp -Rf * /var/www/sub-domains/com.yourdomain.nextcloud/html/`

OR

`mv * /var/www/sub-domains/com.yourdomain.nextcloud/html/`

Now that everything is where it should be, the next step is to make sure that apache owns the directory. To do this, run:

`chown -Rf apache.apache /var/www/sub-domains/com.yourdomain.nextcloud/html`

For security reasons, we also want to move the "data" folder from inside to outside of the _DocumentRoot_. Do this with the following command:

`mv /var/www/sub-domains/com.yourdomain.nextcloud/html/data /var/www/sub-domains/com.yourdomain.nextcloud/`

### Configuring Nextcloud

Now comes the fun! First, make sure that you have your services running. If you followed the above steps, they should already be running. We have had several steps between those initial service starts, so let's go ahead and restart them, just to be sure:

```
systemctl restart httpd
systemctl restart mariadb
```

If everything restarts and there are no issues, then you are ready to move on.

To do the initial configuration, we want to actually load the site in a web browser:

`http://nextcloud.yourdomain.com/`

And you should see this screen:

![nextcloud login screen](../images/nextcloud_screen.jpg)

There are a couple of things that we want to do differently than the defaults that show up:

* At the top of the web page, where it says "Create an admin account", set the user and password. For the sake of this document, we are entering "admin" and setting a strong password. Remember to save this somewhere safe (like a password manager) so that you don't lose it! Even though you have typed into this field, don't hit 'Enter' until we have done all of the setup fields!
* Under the "Storage & database" section, change the "Data folder" location from the default document root, to where we moved the data folder earlier: `/var/www/sub-domains/com.yourdomain.nextcloud/data`
* Under the "Configure the database" section, change from "SQLite" to "MySQL/MariaDB" by clicking on that button.
* Type the MariaDB root user and password that you set earlier into the "Database user" and "Database password" fields
* In the "Database name" field, type "nextcloud"
* In the "localhost" field, type "localhost:3306" (3306 is the default _mariadb_ connect port)

Now cross your fingers and click "Finish Setup".

The browser window will refresh for a bit and then usually not reload the site. Enter your URL in the browser window again and you should be confronted with the default first pages.

Your administrative user is already (or should be) logged in at this point, and there are several informational pages designed to get you up to speed. The "Dashboard" is what users will see when they first login. The administrative user can now create other users, install other applications and many other tasks.

The "Nextcloud Manual.pdf" file is the user manual, so that users can get familiar with what is available. The administrative user should read through or at least scan the high points of the admin manual [On the Nextcloud web site](https://docs.nextcloud.com/server/21/admin_manual/)

## Next Steps

At this point, don't forget that this is a server that you will be storing company data on. It's important to get it locked down with a firewall, get the [backups setup](../backup/rsnapshot_backup.md), secure the site with an [SSL](../security/generating_ssl_keys_lets_encrypt.md), and any other duties that are required to keep your data safe.

## Conclusions
A decision to take the company cloud in house is one that needs to be evaluated carefully. For those that decide that keeping company data locally is preferable over an external cloud host, Nextcloud is a good alternative.
