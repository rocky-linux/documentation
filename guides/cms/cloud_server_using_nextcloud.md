# Cloud Server Using Nextcloud

## Prerequisites And Assumptions

* Server running Rocky Linux (you can install Nextcloud on any Linux distribution, but this procedure will assume you're using Rocky).
* A high degree of comfort operating from the command line for installation and for configuration.
* Knowledge of a command-line editor. For this example, we are using _vi_, but you can use your favorite editor if you have one.
* While Nextcloud can be installed via a snap application, we will be downloading and installing the .zip file.
* We will be applying concepts from the Apache sites enabled document (linked to later in this document) for directory setup.
* We will also be using the _mariadb-server_ hardening procedure (also linked to later) for database setup.
* Throughout this document we will assume that you are root, or that you can be by using _sudo_.
* We are using an example domain of "yourdomain.com" throughout this document.

## Introduction

If you are in charge of a server environment for a large (or even a small) company, you may be tempted by cloud applications. Doing things in the cloud can free up your own resources for other things, but there is a downside to this, and that is the loss of control of your company's data. If the cloud application is compromised, so too may be your company's data.

Taking the cloud back into your own environment is a way to reclaim security of your data at the expense of your time and energy. Sometimes, that is a cost worth paying.

Nextcloud offers an open source cloud with security and flexibility in mind. Note that building a Nextcloud server is a good exercise, even if in the end you opt to take your cloud off-site. The following procedure deals with setting up Nextcloud on Rocky Linux.

## Installing And Configuring Repositories

For this installation, we will require two repositories. We need to install the EPEL (Extra Packages for Enterprise Linux) and the Remi Repository for PHP 7.4 (version 7.3 or 7.4 is required and Rocky Linux provides 7.2.x).

To install the EPEL run:

`dnf install epel-release`

And then once installed, run an update to make sure you are at the very latest epel version:

`dnf update`

To install the Remi repository run:

`dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm`

Run the following to see a list of php modules that can be enabled:

`dnf module list php`

Which should give you output like this:

```
CentOS Linux 8 - AppStream
Name                   Stream                         Profiles                                    Summary                                
php                    7.2 [d]                        common [d], devel, minimal                  PHP scripting language                 
php                    7.3                            common [d], devel, minimal                  PHP scripting language                 
php                    7.4                            common [d], devel, minimal                  PHP scripting language                 

Remi's Modular repository for Enterprise Linux 8 - x86_64
Name                   Stream                         Profiles                                    Summary                                
php                    remi-7.2                       common [d], devel, minimal                  PHP scripting language                 
php                    remi-7.3                       common [d], devel, minimal                  PHP scripting language                 
php                    remi-7.4                       common [d], devel, minimal                  PHP scripting language                 
php                    remi-8.0                       common [d], devel, minimal                  PHP scripting language                 

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

We want to grab the newest PHP that Nextcloud is compatible with, which at this moment is 7.4, so we will enable that module by doing:

`dnf module enable php:remi-7.4`

To see how this changes the output of the module list, run that command again and you will see the "[e]" next to remi-7.4:

`dnf module list php`

And the output again is the same except for this line:

`php                    remi-7.4 [e]                   common [d], devel, minimal                  PHP scripting language`

## Installing Packages

We need a lot of packages installed. Some of these may already be installed with your default Rocky Linux installation, but make sure by running the following command the following:

`dnf install httpd mariadb-server vim wget zip unzip libxml2 openssl php74-php php74-php-ctype php74-php-curl php74-php-gd php74-php-iconv php74-php-json php74-php-libxml php74-php-mbstring php74-php-openssl php74-php-posix php74-php-session php74-php-xml php74-php-zip php74-php-zlib php74-php-pdo php74-php-mysqlnd php74-php-intl php74-php-bcmath php74-php-gmp`

## Configuring Packages And Directories

### Configuring apache

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

### Configuring PHP

Find your timezone. This can be done by:

`cd /usr/share/zoneinfo`

If you are in the Central timezone, for instance, you could either use "US/Central" or "America/Chicago" and either setting would work. Once you have identified your timezone, the next thing we need to do is populate the php.ini file with this information.

To do this:

`vi /etc/opt/remi/php74/php.ini`

Then find this line:

`;date.timezone =`

For our example timezone, we would put in either of the two options:

`date.timezone = "America/Chicago"`

OR

`date.timezone = "US/Central"`

Note that for the sake of keeping things the same, your timezone in the _php.ini_ file should match up to your machine's timezone setting. You can find out what this is set to by doing the following:

`ls -al /etc/localtime`

Which should show you something like this, assuming you set your timezone when you installed Rocky Linux and are living in the Central time zone:

`/etc/localtime -> /usr/share/zoneinfo/America/Chicago`

### Configuring mariadb-server

Set _mariadb-server_ to start on boot:

`systemctl enable mariadb`

And then start it:

`systemctl restart mariadb`

Again, as indicated earlier, we will be using the setup procedure for hardening _mariadb-server_ found [here](../database/database_mariadb-server.md) for the initial configuration.

## Installing Nextcloud

There are several ways to install Nextcloud which you can review on the web site under the manual for installation. What we will be using here is the server install .zip file.

### Get The Nextcloud .zip File And Unzip

The next few steps assume that you are remotely connected to your Nextcloud server via _ssh_ with a remote console open:

* Navigate to the [Nextcloud web site](https://nextcloud.com/)
* Let your mouse hover over "Get Nextcloud" which will bring up a drop down menu.
* Click on "Server Packages".
* Right-click on "Download Nextcloud" and copy the link address. (the exact syntax of this is different browser to browser)
* In your remote console on the Nextcloud server, type "wget" and then a space and paste in what you just copied. You should get something like the following: `wget https://download.nextcloud.com/server/releases/nextcloud-21.0.1.zip`
* Once you hit enter, the download of the .zip file will start and will be completed fairly quickly.

Once the download is complete, unzip the nextcloud zip file by using the following:

`unzip nextcloud-21.0.1.zip`

### Copying Content And Changing Permissions

After completing the unzip step, you should now have a new directory in /root called "nextcloud." Change into this directory:

`cd nextcloud`

And either copy or move the content to our _DocumentRoot_:

`cp -Rf * /var/www/sub-domains/com.yourdomain.nextcloud/html/`

OR

`mv * /var/www/sub-domains/com.yourdomain.nextcloud/html/`

Now that everything is where it should be, the next step is to make sure that apache owns the directory. To do this:

`chown -Rf apache.apache /var/www/sub-domains/com.yourdomain.nextcloud/html`

For security reasons, we also want to move the "data" folder from inside to outside of the _DocumentRoot_. Do this with the following command:

`mv /var/www/sub-domains/com.yourdomain.nextcloud/html/data /var/www/sub-domains/com.yourdomain.nextcloud/`

### Configuring Nextcloud

Now comes the fun! First, make sure that you have your services running. If you followed the above steps, they should already be running. We have had several steps between those initial service starts, so let's go ahead and restart them, just to be sure:

```plain text
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

The browser window will refresh for a bit and then usually not reload the site. Enter your URL in the browser window again and you should be confronted with the default first pages. Your administrative user is already (or should be) logged in at this point, and there are several informational pages designed to get you up to speed.

The "Dashboard" is what users will see when they first login. The administrative user can now create other users, install other applications and many other tasks.

The "Nextcloud Manual.pdf" is the user manual, so that users can get familiar with what is available. The administrative user should read through or at least scan the high points of the admin manual [On the Nextcloud web site](https://docs.nextcloud.com/server/21/admin_manual/)

### Next Steps

At this point, don't forget that this is a server that you will be storing company data on. It's important to get it locked down with a firewall, get the [backups setup](../backup/rsnapshot_backup.md), secure the site with an [SSL](../security/generating_ssl_keys_lets_encrypt.md), and any other duties that are required to keep your data safe.

## Conclusions

A decision to take the company cloud in house is one that needs to be evaluated carefully. For those that decide that keeping company data locally is preferable over an external cloud host, Nextcloud is a good alternative.
