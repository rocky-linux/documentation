---
title: MediaWiki
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 10.0
tags:
  - cms
---

## Introduction

[MediaWiki](https://www.mediawiki.org/wiki/MediaWiki) is a popular open source Wiki software engine powering sites such as Wikipedia, Fandom, and wikiHow, among others.

## Prerequisites and assumptions

The following are the minimum requirements for using this procedure:

* The ability to run commands as the root user or use `sudo` to elevate privileges
* Familiarity with a command-line editor. The author is using `vi` or `vim` here, but substitute in your favorite editor

## Installing Apache

Apache is the web server you will use. Install it with:

```bash
dnf -y install httpd
```

Next, open the corresponding firewall ports:

```bash
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload
```

## Installing PHP

To install PHP, you need first to install the EPEL (Extra Packages for Enterprise Linux):

```bash
dnf -y install epel-release && dnf -y update
```

You also need the Remi repository. Install it with the following:

```bash
dnf install https://rpms.remirepo.net/enterprise/remi-release-10.rpm
```

Then install PHP and the required modules:

```bash
dnf install -y dnf install php84-php-fpm php84-php-intl php84-php-mbstring php84-php-apcu php84-php-curl php84-php-mysql php84-php-xml
```

Enable PHP with:

```bash
systemctl enable --now php84-php-fpm.service
```

## Installing MariaDB

You need MariaDB for the database. Install it with:

```bash
dnf install mariadb-server
```

Next enable the `systemd` service and run the setup wizard:

```bash
systemctl enable --now mariadb
mysql_secure_installation
```

When asked for the root password press ++enter++ :

```bash
Enter current password for root (++enter++ for none):
```

Answer ++"n"++ to `unix_socket` authentication:

```bash
Switch to unix_socket authentication [Y/n] n
```

 Answer ++"Y"++ to changing the root password and enter the needed root password:

```bash
Change the root password? [Y/n] Y
New password: 
Re-enter new password: 
```

Remove the anonymous users and disallow remote `root` logins:

```bash
Remove anonymous users? [Y/n] Y
...
Disallow root login remotely? [Y/n] Y
```

Remove access to the test database and reload privilege tables:

```bash
Remove test database and access to it? [Y/n] Y
...
Reload privilege tables now? [Y/n] Y
```

Login to MariaDB with:

```bash
mysql -u root -p
```

Enter the root password you created earlier.

When you are in the MariaDB console, create the database for MediaWiki:

```bash
MariaDB [(none)]> create database mediawiki;
```

Next, create the MediaWiki user:

```bash
MariaDB [(none)]> create user 'mediawiki'@'localhost' identified by 'nchauhan11';
```

Grant privileges on the MediaWiki database:

```bash
grant all privileges on mediawiki.* to 'mediawiki'@'localhost';
```

Finally, flush the privileges with:

```bash
MariaDB [(none)]> flush privileges;
```

## Installing MediaWiki

Go to the `/var/www/` directory and download MediaWiki:

```bash
cd /var/www/
wget https://releases.wikimedia.org/mediawiki/1.44/mediawiki-1.44.0.zip
```

Unzip and move MediaWiki:

```bash
unzip mediawiki-1.44.0.zip
mv mediawiki-1.44.0/* html/
```

Set the correct SELinux permissions:

```bash
chown -R apache:apache /var/www/html
semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/html(/.*)?"
restorecon -Rv /var/www/html
```

Enable Apache:

```bash
systemctl enable --now httpd
```

Next, open a browser to `http://your_ip` (Replace `your_ip` with your IP address):

![MediaWiki Initial Setup](../images/mediawiki_1.png)

Select your language and click **Continue**:

![MediaWiki Language Page](../images/mediawiki_2.png)

Check to see if the PHP configuration is correct, scroll down and click **Continue**:

![MediaWiki PHP Checks](../images/mediawiki_3.png)

Now, enter the database information as follows:

* **Database host**: `localhost`

* **Database name (no hyphens)**: `mediawiki` (or the database created in the **MariaDB** step)

* **Database username:**: `mediawiki` (or the user created in the **MariaDB** step)

* **Database password**: The password you created in the **MariaDB** step

![MediaWiki Database Information](../images/mediawiki_4.png)

Click **Continue**:

![MediaWiki Database Access Settings](../images/mediawiki_5.png)

In the **MediaWiki *version* installation** page, enter the following:

* **URL host name**: The URL you want

* **Name of wiki**: The Wiki name you want

* **Administrator account**/**Your username**: The admin username you want to use

* **Administrator account**/**Password (again)**: The admin password you want to use

* **Administrator account**/**Email address**: The email address of the admin user

Optionally, you can also select **Ask me more questions** to fine-tune the Wiki. For simplicity's sake, just select **I'm bored already, just install the wiki** and click **Continue**:

![MediaWiki Wiki Information](../images/mediawiki_6.png)

Click **Continue** to install the Wiki:

![MediaWiki Install Step Part 1](../images/mediawiki_7.png)

MediaWiki will set up the databases. When it finishes, click **Continue**:

![MediaWiki Install Step Part 2](../images/mediawiki_8.png)

Your browser will download a `LocalSettings.php` file. You will upload this to your server with `sftp`.

As an example, the author will use their Fedora 42 laptop to upload this file. To do so:

```bash
sftp root@your_ip
(Enter password)
cd /var/www/html
put LocalSettings.php 
```

![MediaWiki LocalSettings.php Step](../images/mediawiki_9.png)

Finally, click **enter your wiki**:

![Fresh MediaWiki Wiki](../images/mediawiki_10.png)

You now have a fresh MediaWiki installation.

## Conclusion

While MediaWiki is best known for powering Wikipedia, it is useful as a content management system where users need the ability to edit pages. MediaWiki is a good open source alternative to Microsoft's SharePoint.
