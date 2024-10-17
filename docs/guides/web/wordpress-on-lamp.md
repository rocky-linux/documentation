---
title: WordPress on LAMP
author: Joseph Brinkman
contributors: 
tested_with: 9.2
---

# WordPress on LAMP

## Prerequisites

- A Rocky Linux 9.x system
- Sudo privileges

## Introduction

WordPress is an open-source content management system (CMS) famous for its [famous 5 minute install](https://developer.wordpress.org/advanced-administration/before-install/howto-install/). It is commonly deployed on a LAMP (Linux, Apache, MySQL, PHP) stack. Although efficient local development tools such as [XAMPP](https://www.apachefriends.org/), [Vagrant](https://www.vagrantup.com/), and [wp-env](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/) are widely available, manually installing WordPress on LAMP for local development provides a valuable hands-on approach for beginners seeking greater understanding.

This guide assumes you already have Rocky 9.x Linux installed, thereby covering the 'L' portion of the LAMP stack.

The goal of this guide is exploring how you can manually install WordPress using the LAMP stack on a Rocky 9 Linux machine. This is not a production-ready guide but a starting point to build off of. The LAMP setup included in this guide can't be recommended for anything other than local development without first taking proper security measures requiring additional configuration.  

## Upgrade system packages

Ensure your system's packages are up-to-date:

```bash
    sudo dnf upgrade -y
```

## Install apache

Apache is a web server and is what will be serving our WordPress site. Install it:

```bash
    sudo dnf install httpd -y
```

## Enable Apache to start on boot

Once apache is installed, enable it so it starts automatically on boot:

```bash
    sudo systemctl enable --now httpd
```

## Install MariaDB

WordPress stores dynamic content in a MySQL database. MariaDB is an open-source fork of MySQL. Install it:

```bash
    sudo dnf install mariadb-server -y
```

## Enable MariaDB server

Once MariaDB is installed, enable it so it starts automatically on boot:

```bash    
    sudo systemctl enable --now mariadb
```

## Secure MariaDB

Run the `mysql_secure_installation` script:

```bash
    sudo mysql_secure_installation --use-default
```

This script performs the following:

1. Sets a root password if one is not already set

2. Removes anonymous users

3. Disallows remote root login

4. Removes access to the test database

5. Reloads privileges

## Install PHP

PHP is the programming used to interact with the MySQL database and perform dynamic actions. It is heavily used in WordPress core, themes, and plugins. 

Install PHP and necessary packages to connect to MySQL:

```bash
    sudo dnf install php php-mysqlnd php-gd php-xml php-mbstring
```

Once PHP is installed you must reload Apache to install it as an apache module and read its configuration files:

## Restart Apache

```bash
    sudo systemctl restart httpd
```

Use `curl` to download the latest version of WordPress:

## Fetch and Unpack WordPress

```bash
    curl -O https://wordpress.org/latest.tar.gz
```

User `tar` to extract the downloaded archive:

```bash
    tar -xzvf latest.tar.gz
```

Copy the WordPress files to Apache's default public directory:

```bash
   sudo cp -r wordpress/* /var/www/html 
```

## Set Owner

Make Apache the owner of the files:

```bash
    sudo chown -R apache:apache /var/www/html/
```

Set permissions for the WordPress files:

## Set Permissions

```bash
    sudo chmod -R 755 /var/www/html/
```

Login to the MySQL CLI:

## Configure Database

```bash
    sudo mysql -u root -p
```

Create a new database for your WordPress website:

## Create a New Database

```bash
    CREATE DATABASE LOCALDEVELOPMENTENV;
```

Create a user with a password for your database:

!!!Note

	It is highly reccomended to use a stronger password. 

## Create a New User and Password

```bash
    CREATE USER 'admin'@'localhost' IDENTIFIED BY 'password';
```

Grant all privileges to your WordPress database to the user you just created:

```bash
    GRANT ALL PRIVILEGES ON LOCALDEVELOPMENTENV.* TO 'admin'@'localhost';
```

Flush privileges to ensure changes are applied:

```bash
    FLUSH PRIVILEGES;
```

Exit the MySQL CLI:

```bash
    EXIT;
```

## Configure WordPress

Copy the `wp-config-sample.php` template and rename it:

```bash
    sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
```

Open the `wp-config.php` file with your choice of text editor:

```bash
    sudo vi /var/www/html/wp-config.php
```

## Replace database settings

You must define the following constants in your `wp-config.php` file:

```bash
    define ('DB_NAME', 'LOCALDEVELOPMENTENV');
    define ('DB_USER', 'admin');
    define ('DB_PASSWORD', 'password');
```

## Configure firewall

Open up HTTP/HTTPS services in your firewall:

```bash
    sudo firewall-cmd --add-service=http --add-service=https
```

Reload `firewalld` to ensure changes to take effect:

```bash
    sudo systemctl reload firewalld
```

## SE Linux settings

Run the below command to allow Apache read an write to your WordPress files:

```bash
   chcon -R -t httpd_sys_rw_content_t /var/www/html/ 
```

Run the below command to allow Apache to make network connections:

!!! Note

    The `-P` flag makes this configuration persistent across reboots

```bash
    setsebool -P httpd_can_network_connect true
```

## Conclusion

Congratulations! You should now be able to connect to WordPress across the network using the hostname or private IP address of the server and finish the WordPress install! Remember, this setup is primarily intended for local development purposes. Additional configurations would need to be made for production use: setting a domain name, installing an SSL certificate, hardening your Apache server, fine tuning your SElinux configuration, and implementing backups. Nevertheless, by following this guide you've created a solid starting point for WordPress development on a LAMP stack!
