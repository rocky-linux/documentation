---
title: Apache With 'mod_ssl'
author: Garthus
contributors: Steven Spencer, David Hensley
update: 20-Jan-2022
---

# 'mod_ssl' on Rocky Linux in an httpd Apache Web-Server Environment

Apache Web-Server has been used for many years now; 'mod_ssl' is used to provide greater security for the Web-Server and can be installed on almost any version of Linux, including Rocky Linux. The installation of 'mod_ssl' will be part of the creation of a Lamp-Server for Rocky Linux.

This procedure is designed to get you up and running with Rocky Linux using 'mod_ssl' in an Apache Web-Server environment..

## Prerequisites

* A Workstation or Server, preferably with Rocky Linux already installed.
* You should be in the Root environment or type `sudo` before all of the commands you enter.

## Install Rocky Linux Minimal

When installing Rocky Linux, we used the following sets of packages:

* Minimal
* Standard

## Run System Update

First, run the system update command to let the server rebuild the repository cache, so that it could recognize the packages available.

`dnf update`

## Enabling Repositories

With a conventional Rocky Linux Server Installation all necessary Repositories should be in place.

## Check The Available Repositories

Just to be sure check your Repository Listing with:

`dnf repolist`

You should get the following back showing all of the enabled repositories:

```
appstream                                                        Rocky Linux 8 - AppStream
baseos                                                           Rocky Linux 8 - BaseOS
extras                                                           Rocky Linux 8 - Extras
powertools                                                       Rocky Linux 8 - PowerTools
```

## Installing Packages

To install 'mod_ssl', run:

`dnf install mod_ssl`

To enable the 'mod_ssl' module, run:

`apachectl restart httpd`
`apachectl -M | grep ssl`

You should see an output as such:

  `ssl_module (shared)`

## Open TCP port 443

To allow incoming traffic with HTTPS, run:

```
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload
```

At this point you should be able to access the Apache Web-Server via HTTPS. Enter `https://your-server-ip` or `https://your-server-hostname` to confirm the 'mod_ssl' configuration.

## Generate SSL Certificate

To generate a new self-signed certificate for Host rocky8 with 365 days expiry, run:

`openssl req -newkey rsa:2048 -nodes -keyout /etc/pki/tls/private/httpd.key -x509 -days 365 -out /etc/pki/tls/certs/httpd.crt`

You will see the following output:

```
Generating a RSA private key
................+++++
..........+++++
writing new private key to '/etc/pki/tls/private/httpd.key'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:AU
State or Province Name (full name) []:
Locality Name (eg, city) [Default City]:
Organization Name (eg, company) [Default Company Ltd]:LinuxConfig.org
Organizational Unit Name (eg, section) []:
Common Name (eg, your name or your server's hostname) []:rocky8
Email Address []:
```
After this command completes execution, the following two SSL files will be created, run:

```
ls -l /etc/pki/tls/private/httpd.key /etc/pki/tls/certs/httpd.crt

-rw-r--r--. 1 root root 1269 Jan 29 16:05 /etc/pki/tls/certs/httpd.crt
-rw-------. 1 root root 1704 Jan 29 16:05 /etc/pki/tls/private/httpd.key
```

## Configure Apache Web-Server with New SSL Certificates

To include your newly created SSL certificate into the Apache web-server configuration open the ssl.conf file by running:

`nano /etc/httpd/conf.d/ssl.conf`

Then change the following lines:

FROM:
```
SSLCertificateFile /etc/pki/tls/certs/localhost.crt
SSLCertificateKeyFile /etc/pki/tls/private/localhost.key
```
TO:
```
SSLCertificateFile /etc/pki/tls/certs/httpd.crt
SSLCertificateKeyFile /etc/pki/tls/private/httpd.key
```

Then reload the Apache Web-Server by running:

`systemctl reload httpd`

## Test the 'mod_ssl' configuration

Enter the following in a web browser:

`https://your-server-ip` or `https://your-server-hostname`

## To Redirect All HTTP Traffic To HTTPS

Create a new file by running:

`nano /etc/httpd/conf.d/redirect_http.conf`

Insert the following content and save file, replacing "your-server-hostname" with your hostname.

```
<VirtualHost _default_:80>

        Servername rocky8
        Redirect permanent / https://your-server-hostname/

</VirtualHost/>
```

Apply the change when reloading the Apache service by running:

`systemctl reload httpd`

The Apache Web-Server will now be configured to  redirect any incoming traffic from `http://your-server-hostname` to `https://your-server-hostname` URL.

## Final Steps

We have seen how to install and configure 'mod_ssl'. And, create a new SSL Certificate in order to run a Web-Server under HTTPS Service.

## Conclusion

This tutorial will be part of the tutorial covering installing a LAMP (Linux, Apache Web-Server, Maria Database-Server, and PHP Scripting Language), Server on Rocky Linux version 8.x. Eventually we will be including images to help better understand the installation.
