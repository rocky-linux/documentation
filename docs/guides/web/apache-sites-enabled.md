---
title: Apache Multiple Site
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - web
  - apache
  - multiple site
---

# Apache web server multiple site setup

## What you need

* A server running Rocky Linux
* Knowledge of the command-line and text editors. This example uses *vi*, but feel free to use your favorite editor.

    !!! tip

        If you'd like to learn about the vi text editor, [here's a handy tutorial](https://www.tutorialspoint.com/unix/unix-vi-editor.htm).

* Basic knowledge of installing and running web services

## Introduction

Rocky Linux has many ways for you to set up a website. This is just one method, using Apache on a single server. The design of this method is for multiple servers on one piece of hardware, but it can also act as a base configuration for a single site server.

Historical fact: This server setup appears to have started with Debian-based systems, but it is perfectly adaptable to any Linux operating system running Apache.

For those looking for a similar setup for Nginx, [examine this guide](nginx-multisite.md).

## Install Apache
You will likely need other packages for your website, such as PHP, database, or other packages. Installing PHP along with `http` will get you the most recent version from the Rocky Linux repositories.

Just remember that you may need modules, such as `php-bcmath` or `php-mysqlind`. Your web application specifications will dictate what you need. You can install these when needed. For now, you will install `http` and PHP, as those are almost a forgone conclusion:

From the command-line run:

```
dnf install httpd php
```

## Add extra directories

This method uses a couple of additional directories, which do not currently exist on the system. You need to add two directories in */etc/httpd/* called "sites-available" and "sites-enabled."

From the command-line enter: 

```
mkdir -p /etc/httpd/sites-available /etc/httpd/sites-enabled
```

This will create both needed directories.

You also need a directory where our sites are going to be. This can be anywhere, but a good way to keep things organized is to create a "sub-domains" directory. Put this in /var/www: `mkdir /var/www/sub-domains/` to decrease complexity.

## Configuration

You also need to add a line to the bottom of the `httpd.conf` file. To do this, enter: 

```
vi /etc/httpd/conf/httpd.conf
```

and go to the bottom of the file and add:

```
Include /etc/httpd/sites-enabled
```

Our actual configuration files will be in */etc/httpd/sites-available* and you will symlink to them in */etc/httpd/sites-enabled*.

**Why do you do this?**

Say you have 10 websites all running on the same server on different IP addresses. Say that site B has some major updates, and you have to make changes to the configuration for that site. Say also that something goes wrong with the changes made, and when you restart `httpd` to read in the changes, `httpd` does not start. Not only will the site you were working on not start, but neither will the rest of them. With this method, you can remove the symbolic link for the site that caused the problem, and restart `httpd`. It will start working again, and you fix the broken site's configuration.

It takes the pressure off, knowing the telephone will not ring with some upset customer or boss because a service is off-line.

### The site configuration

The other benefit of this method is that it allows us to fully specify everything outside the default `httpd.conf` file. The default `httpd.conf` file loads the defaults, and your site configurations do everything else. Great, right? Plus again, it makes troubleshooting a broken site configuration less complex.

Say you have a website that loads a wiki. You will need a configuration file, which makes the site available on port 80.

If you want to serve the website with SSL/TLS (and face it, in most cases you do), you need to add another (nearly the same) section to that file to enable port 443.

You can examine that below in the [Configuration `https` using An SSL/TLS certificate](#https) section.

You first need to create this configuration file in *sites-available*: 

```
vi /etc/httpd/sites-available/com.wiki.www
```

The configuration file content will look something like this:

```apache
<VirtualHost *:80>
        ServerName your-server-hostname
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/your-server-hostname/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/
        # ScriptAlias /cgi-bin/ /var/www/sub-domains/your-server-hostname/cgi-bin/

	CustomLog "/var/log/httpd/your-server-hostname-access_log" combined
	ErrorLog  "/var/log/httpd/your-server-hostname-error_log"

        <Directory /var/www/sub-domains/your-server-hostname/html>
                Options -ExecCGI -Indexes
                AllowOverride None

                Order deny,allow
                Deny from all
                Allow from all

                Satisfy all
        </Directory>
</VirtualHost>
```

When created, you need to write (save) it with ++shift+:+wq++.

In the example, loading the wiki site happens from the "html" subdirectory of _your-server-hostname_, which means that the path you created in _/var/www_ (above) will need some additional directories to satisfy this:

```
mkdir -p /var/www/sub-domains/your-server-hostname/html
```

This will create the entire path with a single command. Next you want to install your files to this directory that will actually run the website. This might be something you made yourself, or an installable web application (in this case a wiki) that you downloaded.

Copy your files to the path you created:

```
cp -Rf wiki_source/* /var/www/sub-domains/your-server-hostname/html/
```

## <a name="https"></a>Configuration `https` using an SSL/TLS certificate

As stated earlier, every web server created these days _should_ be running with SSL/TLS (the secure socket layer).

This process starts by generating a private key and CSR (certificate signing request) and submitting the CSR to the certificate authority to buy the SSL/TLS certificate. The process of generating these keys is somewhat extensive.

If you are not familiar with SSL/TLS key generation examine: [Generating SSL Keys](../security/ssl_keys_https.md)

You can also use this alternate process, using an [SSL certificate from Let's Encrypt](../security/generating_ssl_keys_lets_encrypt.md)

### Placement of the SSL/TLS keys and certificates

Since you have your keys and certificate files, you need to place them logically in your file system on the web server. As you have seen with the example configuration file, you are placing your web files in _/var/www/sub-domains/your-server-hostname/html_.

You want to place your certificate and key files with the domain, but outside of the document root, which in this case is the _html_ folder.

You never want to risk exposing your certificates and keys to the web. That would be bad!

Instead, you will create a directory structure for our SSL/TLS files, outside the document root:

```
mkdir -p /var/www/sub-domains/your-server-hostname/ssl/{ssl.key,ssl.crt,ssl.csr}`
```

If you are new to the "tree" syntax for making directories, what the above says is:

"Make a directory called "ssl" and make three directories inside called ssl.key, ssl.crt, and ssl.csr."

Just a note ahead of time: Storing the certificate signing request (CSR) file in the tree is not necessary, but it simplifies some things. If you ever need to re-issue the certificate from a different provider, having a stored copy of the CSR is a good idea. The question becomes where can you store it so that you will remember, and storing it within the tree of your website is logical.

Assuming that you have named your key, csr, and crt (certificate) files with the name of your site, and that you have them stored in _/root_, you will copy them up to their locations:

```
cp /root/com.wiki.www.key /var/www/sub-domains/your-server-hostname/ssl/ssl.key/
cp /root/com.wiki.www.csr /var/www/sub-domains/your-server-hostname/ssl/ssl.csr/
cp /root/com.wiki.www.crt /var/www/sub-domains/your-server-hostname/ssl/ssl.crt/
```

### The site configuration - `https`

Once you have generated your keys and purchased the SSL/TLS certificate, you can move forward with the website configuration using your keys.

For starters, break down the beginning of the configuration file. For instance, even though you still want to listen on port 80 (standard `http` port) for incoming requests, you do not want any of those requests to actually go to port 80.

You want them to go to port 443 (or "`http` secure", better known as SSL/TLS or `https`). Our port 80 configuration section will be minimal:


```apache
<VirtualHost *:80>
        ServerName your-server-hostname
        ServerAdmin username@rockylinux.org
        Redirect / https://your-server-hostname/
</VirtualHost>
```

What this says is to send any regular web request to the `https` configuration instead. The apache "Redirect" option shown is temporary. When testing is complete and you can see that the site is running as expected, you can change this to "Redirect permanent."

A permanent redirect will teach the search engines, and soon any traffic to your site that comes from search engines will go only to port 443 (`https`) without hitting port 80 (`http`) first.

Next, you need to define the `https` part of the configuration file:

```apache
<VirtualHost *:80>
        ServerName your-server-hostname
        ServerAdmin username@rockylinux.org
        Redirect / https://your-server-hostname/
</VirtualHost>
<Virtual Host *:443>
        ServerName your-server-hostname
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/your-server-hostname/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/
        # ScriptAlias /cgi-bin/ /var/www/sub-domains/your-server-hostname/cgi-bin/

	CustomLog "/var/log/`http`d/your-server-hostname-access_log" combined
	ErrorLog  "/var/log/`http`d/your-server-hostname-error_log"

        SSLEngine on
        SSLProtocol all -SSLv2 -SSLv3 -TLSv1
        SSLHonorCipherOrder on
        SSLCipherSuite EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384
:EECDH+aRSA+SHA256:EECDH+aRSA+RC4:EECDH:EDH+aRSA:RC4:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS

        SSLCertificateFile /var/www/sub-domains/your-server-hostname/ssl/ssl.crt/com.wiki.www.crt
        SSLCertificateKeyFile /var/www/sub-domains/your-server-hostname/ssl/ssl.key/com.wiki.www.key
        SSLCertificateChainFile /var/www/sub-domains/your-server-hostname/ssl/ssl.crt/your_providers_intermediate_certificate.crt

        <Directory /var/www/sub-domains/your-server-hostname/html>
                Options -ExecCGI -Indexes
                AllowOverride None

                Order deny,allow
                Deny from all
                Allow from all

                Satisfy all
        </Directory>
</VirtualHost>
```

So, breaking down this configuration further, after the normal portions of the configuration and down to the SSL/TLS section:

* SSLEngine on - says to use SSL/TLS
* SSLProtocol all -SSLv2 -SSLv3 -TLSv1 - says to use all available protocols, except those with vulnerabilities. You should research periodically the protocols currently acceptable for use.
* SSLHonorCipherOrder on - this deals with the next line regarding the cipher suites, and says to deal with them in the order shown. This is another area where reviewing the cipher suites should occur periodically.
* SSLCertificateFile - is exactly what it says: the newly purchased and applied certificate file and its location
* SSLCertificateKeyFile - the key you generated when creating your certificate signing request
* SSLCertificateChainFile - the certificate from your certificate provider, often called the intermediate certificate

Take everything live and if no errors exist when starting the web service, and if going to your website reveals `https` without errors, you are ready to go.

## Taking it live

Remember that our *httpd.conf* file is including */etc/httpd/sites-enabled* at the end of the file. When `httpd` restarts, it will load whatever configuration files are in that *sites-enabled* directory. Thing is, all of our configuration files are in *sites-available*.

That is by design, so that you can remove things when or if  `httpd` fails to restart. To enable our configuration file, you need to create a symbolic link to that file in *sites-enabled* and start or restart the web service. To do this, you use this command:

```
ln -s /etc/httpd/sites-available/your-server-hostname /etc/httpd/sites-enabled/
```


This will create the link to the configuration file in *sites-enabled*.

Now just start `httpd` with `systemctl start httpd`. Or restart it if it is already running: `systemctl restart httpd`, and assuming the web service restarts, you can now go and do some testing on your site.
