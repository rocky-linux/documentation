---
title: WordPress on LAMP
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova 
tested_with: 9.2
---

## Prerequisites

- A Rocky Linux 9.x system
- sudo privileges

## Introduction

WordPress is an open-source content management system (CMS) noted for its [famous 5-minute install](https://developer.wordpress.org/advanced-administration/before-install/howto-install/). It is commonly deployed on a LAMP (Linux, Apache, MySQL, PHP) stack. Although efficient local development tools such as [XAMPP](https://www.apachefriends.org/), [Vagrant](https://www.vagrantup.com/), and [wp-env](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/) are widely available, manually installing WordPress on LAMP for local development provides a valuable hands-on approach for beginners seeking greater understanding.

This guide assumes you already have Rocky Linux 9.x installed, thereby covering the 'L' part of the LAMP stack.

This guide explores how to manually install WordPress with the LAMP stack on a Rocky Linux 9 machine. This is not a production-ready guide but a starting point to build on. The LAMP setup included in this guide is not recommended for anything other than local development without first taking proper security measures requiring additional configuration.  

## Upgrade system packages

Ensure your system's packages are up-to-date:

```bash
    sudo dnf upgrade -y
```

## Install Apache

Apache is a web server that will serve your WordPress site. Install it with the following:

```bash
    sudo dnf install httpd -y
```

## Enable Apache to start on boot

After installing Apache, enable it so it starts automatically on boot:

```bash
    sudo systemctl enable --now httpd
```

## Install MariaDB

WordPress stores dynamic content in a MySQL database. MariaDB is an open source fork of MySQL. Install it with the following:

```bash
    sudo dnf install mariadb-server -y
```

## Enable MariaDB server

After installing MariaDB, enable it so it starts automatically on boot:

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

After installing PHP, you must reload Apache to install it as an Apache module and read its configuration files:

## Restart Apache

```bash
    sudo systemctl restart httpd
```

Use `curl` to download the latest version of WordPress:

## Fetch and unpack WordPress

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

## Set owner

Make Apache the owner of the files:

```bash
    sudo chown -R apache:apache /var/www/html/
```

Set permissions for the WordPress files:

## Set permissions

```bash
    sudo chmod -R 755 /var/www/html/
```

Login to the MySQL CLI:

## Configure database

```bash
    sudo mysql -u root -p
```

Create a new database for your WordPress website:

## Create a new database

```bash
    CREATE DATABASE LOCALDEVELOPMENTENV;
```

Create a user with a password for your database:

!!! Note

    It is highly reccomended to use a stronger password.

## Create a new user and password

```bash
    CREATE USER 'admin'@'localhost' IDENTIFIED BY 'password';
```

Grant all privileges to your WordPress database to the user you just created:

```bash
    GRANT ALL PRIVILEGES ON LOCALDEVELOPMENTENV.* TO 'admin'@'localhost';
```

Flush privileges to ensure the application of changes:

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

Open up HTTP and HTTPS services in your firewall:

```bash
    sudo firewall-cmd --add-service=http --add-service=https
```

Reload `firewalld` to ensure changes to take effect:

```bash
    sudo systemctl reload firewalld
```

## SELinux settings

To allow Apache read and write access to your WordPress files, run this command:

```bash
   chcon -R -t httpd_sys_rw_content_t /var/www/html/ 
```

To allow Apache to make network connections, run this command:

!!! Note

    The `-P` flag makes this configuration persistent across reboots

```bash
    setsebool -P httpd_can_network_connect true
```

## Conclusion

To finish the installation, you should now be able to connect to WordPress across the network using the server's hostname or private IP address. Remember, this setup is primarily intended for local development purposes. For production use, you need to configure the following: set a domain name, install an SSL certificate, harden your Apache server, fine-tune your SELinux configuration, and implement backups. Nevertheless, following this guide has created a solid starting point for WordPress development on a LAMP stack.
