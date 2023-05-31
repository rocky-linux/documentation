---
title: Apache Multisite
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.5, 8.6, 9.0
tags:
  - web
  - apache
  - multisite
---

# Apache Web Server Multisite Setup

## What You Need

* A server running Rocky Linux
* Knowledge of the command-line and text editors (This example uses *vi*, but can be adapted to your favorite editor.)

    !!! tip

        If you'd like to learn about the vi text editor, [here's a handy tutorial](https://www.tutorialspoint.com/unix/unix-vi-editor.htm).

* Basic knowledge about installing and running web services

## Introduction

Rocky Linux has many ways for you to set up a website. This is just one method, using Apache, and is designed for use as a multisite setup on a single server. While this method is designed for multisite servers, it can also act as a base configuration for a single site server as well.

Historical fact: This server setup appears to have started with Debian-based systems, but it is perfectly adaptable to any Linux OS running Apache.

For those looking for a similar setup for Nginx, take a [look at this guide.](nginx-multisite.md)

## Install Apache
You'll likely need other packages for your website. For instance, a version of PHP will almost certainly be required, and maybe a database or other package will be needed as well. Installing PHP along with httpd will get you the latest version of both from the Rocky Linux repositories.

Just remember that you may need modules as well, like perhaps php-bcmath or php-mysqlind. Your web application specifications should detail what is needed. These can be installed at any time. For now, we will install httpd and PHP, as those are almost a forgone conclusion:

* From the command-line run `dnf install httpd php`

## Add Extra Directories

This method uses a couple of additional directories, but they don't currently exist on the system. We need to add two directories in */etc/httpd/* called "sites-available" and "sites-enabled."

* From the command-line type `mkdir /etc/httpd/sites-available` and then `mkdir /etc/httpd/sites-enabled`

* We also need a directory where our sites are going to reside. This can be anywhere, but a good way to keep things organized is to create a directory called sub-domains. To keep things simple, put this in /var/www: `mkdir /var/www/sub-domains/`

## Configuration
We also need to add a line to the very bottom of the httpd.conf file. To do this, type `vi /etc/httpd/conf/httpd.conf` and go to the bottom of the file and add `Include /etc/httpd/sites-enabled`.

Our actual configuration files will reside in */etc/httpd/sites-available* and we will simply symlink to them in */etc/httpd/sites-enabled*.

**Why do we do this?**

The reason here is pretty simple. Let's say you have 10 websites all running on the same server on different IP addresses. We will say, too, that site B has some major updates, and you have to make changes to the configuration for that site. Let's say as well, that there is something wrong with the changes made, so when you restart httpd to read in the new changes, httpd doesn't start.

Not only will the site you were working on not start, but neither will the rest of them. With this method, you can simply remove the symbolic link for the site that caused the failure, and restart httpd. It’ll start working again, and you can go to work, trying to fix the broken site configuration.

It sure takes the pressure off, knowing that the phone isn't going to ring with some angry customer, or an angry boss, because a service is off-line.

### The Site Configuration
The other benefit of this method is that it allows us to fully specify everything outside the default httpd.conf file. Let the default httpd.conf file load the defaults, and let your site configurations do everything else. Sweet, right? Plus again, it makes it very easy to trouble-shoot a broken site configuration.

Now, let's say you have a website that loads a wiki. You’ll need a configuration file, which makes the site available via port 80.

If you want to serve the website with SSL (and let's face it, we all should be doing that by now) then you need to add another (nearly identical) section to the same file, in order to enable port 443.

You can take a look at that below in the [Configuration https - Using An SSL Certificate](#https) section.

So we first need to create this configuration file in *sites-available*: `vi /etc/httpd/sites-available/com.wiki.www`

The configuration file configuration content would look something like this:

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
Once the file is created, we need to write (save) it with: `shift : wq`

In our example above, the wiki site is loaded from the "html" sub-directory of _your-server-hostname_, which means that the path we created in _/var/www_ (above) will need some additional directories to satisfy this:

`mkdir -p /var/www/sub-domains/your-server-hostname/html`

... which will create the entire path with a single command. Next we would want to install our files to this directory that will actually run the website. This could be something you made yourself, or an installable web application (in this case a wiki that you downloaded).

Copy your files to the path above:

`cp -Rf wiki_source/* /var/www/sub-domains/your-server-hostname/html/`

## <a name="https"></a>Configuration https - Using an SSL Certificate

As stated earlier, every web server created these days _should_ be running with SSL (AKA the secure socket layer).

This process starts by generating a private key and a CSR (which stands for certificate signing request) and then submitting the CSR to the certificate authority to purchase the SSL certificate. The process of generating these keys is somewhat extensive, so it has its own document.

If you are new to generating keys for SSL, please take a look at: [Generating SSL Keys](../security/ssl_keys_https.md)

You can also use this alternate process for using an [SSL certificate from Let's Encrypt](../security/generating_ssl_keys_lets_encrypt.md)

### Placement of the SSL keys and Certificate's

Now that you have your keys and certificate files, we need to place them logically in your file system on the web server. As we've seen with the example configuration file (above), we are placing our web files in _/var/www/sub-domains/your-server-hostname/html_.

We want to place our certificate and key files with the domain, but NOT in the document root, which in this case is the _html_ folder.

We never want our certificates and keys to potentially be exposed to the web. That would be bad!

Instead, we will create a new directory structure for our SSL files, outside the document root:

`mkdir -p /var/www/sub-domains/your-server-hostname/ssl/{ssl.key,ssl.crt,ssl.csr}`

If you are new to the "tree" syntax for making directories, what the above says is:

"Make a directory called ssl and then make three directories inside called ssl.key, ssl.crt, and ssl.csr."

Just a note ahead of time: It is not necessary for the functioning of the web server that the CSR file be stored in the tree.

If you ever need to re-issue the certificate from a different provider, etc., it's a good idea to have a stored copy of the CSR file. The question becomes where can you store it so that you will remember, and storing it within the tree of your website is logical.

Assuming that you have named your key, csr, and crt (certificate) files with the name of your site, and that you have them stored in _/root_, we will then copy them up to their respective locations that we just created:

```
cp /root/com.wiki.www.key /var/www/sub-domains/your-server-hostname/ssl/ssl.key/
cp /root/com.wiki.www.csr /var/www/sub-domains/your-server-hostname/ssl/ssl.csr/
cp /root/com.wiki.www.crt /var/www/sub-domains/your-server-hostname/ssl/ssl.crt/
```

### The Site Configuration - https

Once you have generated your keys and purchased the SSL certificate, you can now move forward with the configuration of the website using your new keys.

For starters, let's break down the beginning of the configuration file. For instance, even though we still want to listen on port 80 (standard http) for incoming requests, we don't want any of those requests to actually go to port 80.

We want them to go to port 443 (or http secure, better known as SSL). Our port 80 configuration section will be minimal:

```
<VirtualHost *:80>
        ServerName your-server-hostname
        ServerAdmin username@rockylinux.org
        Redirect / https://your-server-hostname/
</VirtualHost>
```

What this says is to send any regular web request to the https configuration instead. The apache "Redirect" option shown above, can be changed to "Redirect permanent" once all testing is complete, and you can see that the site operates as you want it to. The "Redirect" we have chosen is a temporary redirect.

A permanent redirect will be learned by search engines, and soon, any traffic to your site that comes from search engines will go only to port 443 (https) without hitting port 80 (http) first.

Next, we need to define the https portion of the configuration file. The http section is duplicated here for clarity to show that this all happens in the same configuration file:

```
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

	CustomLog "/var/log/httpd/your-server-hostname-access_log" combined
	ErrorLog  "/var/log/httpd/your-server-hostname-error_log"

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

So, breaking down this configuration further, after the normal portions of the configuration and down to the SSL portion:

* SSLEngine on - simply says to use SSL
* SSLProtocol all -SSLv2 -SSLv3 -TLSv1 - says to use all available protocols, except those that have been found to have vulnerabilities. You should research periodically which protocols are currently acceptable for use.
* SSLHonorCipherOrder on - this deals with the next line that regarding the cipher suites, and says to deal with them in the order that they are given. This is another area where you should review the cipher suites that you want to include periodically
* SSLCertificateFile - is exactly what it sounds like, the newly purchased and applied certificate file and its location
* SSLCertificateKeyFile - the key you generated when creating your certificate signing request
* SSLCertificateChainFile - the certificate from your certificate provider, often referred to as the intermediate certificate.

Next, take everything live and if there are no errors starting the web service and if going to your website reveals HTTPS without errors, then you are ready to go.

## Taking It Live

Remember that our *httpd.conf* file is including */etc/httpd/sites-enabled* at the very end of the file, so when `httpd` restarts, it will load whatever configuration files are in that *sites-enabled* directory. Thing is, all of our configuration files are in *sites-available*.

That's by design, so that we can easily remove things in the event that `httpd` fails to restart. So to enable our configuration file, we need to create a symbolic link to that file in *sites-enabled* and then start or restart the web service. To do this, we use this command:

`ln -s /etc/httpd/sites-available/your-server-hostname /etc/httpd/sites-enabled/`

This will create the link to the configuration file in *sites-enabled*, just like we want.

Now just start httpd with `systemctl start httpd`. Or restart it if it’s already running: `systemctl restart httpd`, and assuming the web service restarts, you can now go and do some testing on your new site.
