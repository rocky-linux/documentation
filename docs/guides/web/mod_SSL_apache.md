---
title: Apache With 'mod_ssl'
author: Garthus
contributors: Steven Spencer, David Hensley, Ganna Zhyrnova
update: 20-Jan-2022
---

# `mod_ssl` on Rocky Linux in an Apache web server environment

The Apache web server has existed for many years now. `mod_ssl` provides greater security for the web server and is installable on almost any version of Linux.

This procedure will get you up and running with Rocky Linux and `mod_ssl` in an Apache web server environment.

## Prerequisites

* A workstation or server, preferably with Rocky Linux already installed.
* Able to run commands as *root*  or `sudo` to elevate privileges.

## Install Rocky Linux Minimal

When installing Rocky Linux, we used the following sets of packages:

* Minimal
* Standard

## Run updates

First, run the system update command to let the server rebuild the repository cache to recognize the packages available.

`dnf update`

## Enabling repositories

With a conventional Rocky Linux server installation, all necessary repositories will be in place.

## Check the available repositories

Just to be sure check your repository listing with:

`dnf repolist`

You will get the following:

```bash
appstream                                                        Rocky Linux 8 - AppStream
baseos                                                           Rocky Linux 8 - BaseOS
extras                                                           Rocky Linux 8 - Extras
powertools                                                       Rocky Linux 8 - PowerTools
```

## Installing packages

To install `mod_ssl`, run:

`dnf install mod_ssl`

To enable the `mod_ssl` module, run:

`apachectl restart httpd`
`apachectl -M | grep ssl`

You will see:

  `ssl_module (shared)`

## Open TCP port 443

To allow incoming traffic with HTTPS, run:

```bash
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload
```

Ensure that your goal is to have the website open to the world when you add this rule! If not, change the zone or configure the firewall to correct that.

At this point you should be able to access the Apache web server via HTTPS. Enter `https://your-server-ip` or `https://your-server-hostname` to confirm the `mod_ssl` configuration.

## Generate SSL/TLS certificate

To generate a self-signed certificate for host rocky8 with 365 days expiry, run:

`openssl req -newkey rsa:2048 -nodes -keyout /etc/pki/tls/private/httpd.key -x509 -days 365 -out /etc/pki/tls/certs/httpd.crt`

You will see the following output:

```bash
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

After this command completes, the following two SSL/TLS files will be there:

```bash
ls -l /etc/pki/tls/private/httpd.key /etc/pki/tls/certs/httpd.crt

-rw-r--r--. 1 root root 1269 Jan 29 16:05 /etc/pki/tls/certs/httpd.crt
-rw-------. 1 root root 1704 Jan 29 16:05 /etc/pki/tls/private/httpd.key
```

## Configure Apache web server with the SSL/TLS certificates

To include your newly created SSL/TLS certificate into the Apache web server configuration open the `ssl.conf` file by running:

`nano /etc/httpd/conf.d/ssl.conf`

Change the following lines:

FROM:

```bash
SSLCertificateFile /etc/pki/tls/certs/localhost.crt
SSLCertificateKeyFile /etc/pki/tls/private/localhost.key
```

TO:

```bash
SSLCertificateFile /etc/pki/tls/certs/httpd.crt
SSLCertificateKeyFile /etc/pki/tls/private/httpd.key
```

Reload the Apache web server by running:

`systemctl reload httpd`

## Test the `mod_ssl` configuration

Enter the following in a web browser:

`https://your-server-ip` or `https://your-server-hostname`

## To redirect all HTTP traffic to HTTPS

Create a new file by running:

`nano /etc/httpd/conf.d/redirect_http.conf`

Insert the following content and save file, replacing "your-server-hostname" with your hostname.

```bash
<VirtualHost _default_:80>

        Servername rocky8
        Redirect permanent / https://your-server-hostname/

</VirtualHost/>
```

Apply the change by running:

`systemctl reload httpd`

The Apache web server will redirect any incoming traffic from `http://your-server-hostname` to `https://your-server-hostname` URL.

## Final steps

You have seen how to install and configure `mod_ssl`, and create a new SSL/TLS certificate to run a web server under HTTPS service.

## Conclusion

This tutorial shows the basic installation and use of `mod_ssl`.
