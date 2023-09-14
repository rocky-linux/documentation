---
title: Generating SSL Keys - Let's Encrypt
author: Steven Spencer
contributors: wsoyinka, Antoine Le Morvan, Ezequiel Bruni, Andrew Thiesen, Ganna Zhyrnova
tested_with: 8.5
tags:
  - security
  - ssl
  - certbot
---

# Generating SSL keys - Let's Encrypt

## Prerequisites & assumptions

* Comfort with the command line
* Familiarity with securing web sites with SSL certificates is a plus
* Knowledge of command line text editors (this example uses _vi_)
* A web server open to the world and running on port 80 (http)
* Familiarity with _ssh_ (secure shell) and the ability to access your server with _ssh_
* All commands assume that you are either the root user or that you have used _sudo_ to gain root access.

## Introduction

One of the most popular ways to secure a web site currently is using Let's Encrypt SSL certificates, which are also free.

These are actual certificates, not self-signed or snake oil, etc., so they are great for a low-budget security solution. This document will walk you through the process of installing and using Let's Encrypt certificates on a Rocky Linux web server.

## Installation

To do the next steps, use _ssh_ to log into your server. If your server's fully qualified DNS name was www.myhost.com, then you would use:

```bash
ssh -l root www.myhost.com
```

Or, if you must access your server as an unprivileged user first. Use your username:

```bash
ssh -l username www.myhost.com
```

And then:

```bash
sudo -s
```

You will need your _sudo_ user's credentials in this case to gain access to the system as root.

Let's Encrypt uses a package called _certbot_ which needs to be installed via the EPEL repositories. Add those first:

```bash
dnf install epel-release
```

Then install the appropriate packages, depending on whether you use Apache or Nginx as your web server. For Apache that is:

```bash
dnf install certbot python3-certbot-apache
```

For Nginx, just change out one package:

```bash
dnf install certbot python3-certbot-nginx
```

You can always install both server modules if necessary.

!!! Note

    An earlier version of this guide required the snap package version of _certbot_, which was necessary at the time. The RPM versions have been re-tested recently, and are working now. That said, Certbot strongly recommends the use of the [snap install procedure](https://certbot.eff.org/instructions?ws=apache&os=centosrhel8). Rocky Linux 8 and 9 have _certbot_ available in the EPEL, so we show that procedure here. If you would like to use the procedure recommended by Certbot, just follow that procedure instead.


## Getting The Let's Encrypt Certificate for the Apache Server

There are two ways to retrieve your Let's Encrypt certificate, either using the command to modify the http configuration file for you, or to just retrieve the certificate. If you are using the procedure for a multi-site setup suggested for one or more sites in the procedure [Apache Web Server Multi-Site Setup](../web/apache-sites-enabled.md), then you will only want to retrieve your certificate.

We are assuming that you **are** using this procedure so we will only retrieve the certificate. If you are running a standalone web server using the default configuration, you can retrieve the certificate and modify the configuration file in one step using:

```bash
certbot --apache
```

That's really the easiest way to get things done. However, sometimes you want to take a more manual approach and grab the certificate. To retrieve the certificate only, use this command:

```bash
certbot certonly --apache
```

Both commands will generate a set of prompts you need to answer. The first is to give an email address for important information:

```
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator apache, Installer apache
Enter email address (used for urgent renewal and security notices)
 (Enter 'c' to cancel): yourusername@youremaildomain.com
```

The next asks you to read and accept the terms of the subscriber agreement. Once you have read the agreement answer 'Y' to continue:

```
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please read the Terms of Service at
https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf. You must
agree in order to register with the ACME server. Do you agree?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o:
```

The next is a request to share your email with the Electronic Frontier Foundation. Answer 'Y' or 'N' as is your preference:

```
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Would you be willing, once your first certificate is successfully issued, to
share your email address with the Electronic Frontier Foundation, a founding
partner of the Let's Encrypt project and the non-profit organization that
develops Certbot? We'd like to send you email about our work encrypting the web,
EFF news, campaigns, and ways to support digital freedom.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o:
```

The next prompt asks you which domain you want the certificate for. It should display a domain in the listing based on your running web server. If so, enter the number next to the domain for which you are getting the certificate. In this case there is only one option ('1'):

```
Which names would you like to activate HTTPS for?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: yourdomain.com
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate numbers separated by commas and/or spaces, or leave input
blank to select all options shown (Enter 'c' to cancel):
```

If all goes well, you should receive the following message:

```
Requesting a certificate for yourdomain.com
Performing the following challenges:
http-01 challenge for yourdomain.com
Waiting for verification...
Cleaning up challenges
Subscribe to the EFF mailing list (email: yourusername@youremaildomain.com).

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/yourdomain.com/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/yourdomain.com/privkey.pem
   Your certificate will expire on 2021-07-01. To obtain a new or
   tweaked version of this certificate in the future, simply run
   certbot again. To non-interactively renew *all* of your
   certificates, run "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le
```

## The Site Configuration - https

Applying the configuration file to our site is slightly different than if we were using a purchased SSL certificate from another provider (and if we didn't let _certbot_ do it automatically).

A single PEM (Privacy Enhanced Mail) file includes the certificate and chain file. This is a common format for all certificate files now, so even though it has "Mail" in the reference, it is just a type of certificate file. To illustrate the configuration file, we will show it in it's entirety and then describe what is happening:

```
<VirtualHost *:80>
        ServerName www.yourdomain.com
        ServerAdmin username@rockylinux.org
        Redirect / https://www.yourdomain.com/
</VirtualHost>
<Virtual Host *:443>
        ServerName www.yourdomain.com
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/com.yourdomain.www/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/
        # ScriptAlias /cgi-bin/ /var/www/sub-domains/com.yourdomain.www/cgi-bin/

	CustomLog "/var/log/httpd/com.yourdomain.www-access_log" combined
	ErrorLog  "/var/log/httpd/com.yourdomain.www-error_log"

        SSLEngine on
        SSLProtocol all -SSLv2 -SSLv3 -TLSv1
        SSLHonorCipherOrder on
        SSLCipherSuite EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384
:EECDH+aRSA+SHA256:EECDH+aRSA+RC4:EECDH:EDH+aRSA:RC4:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS

        SSLCertificateFile /etc/letsencrypt/live/yourdomain.com/fullchain.pem
        SSLCertificateKeyFile /etc/letsencrypt/live/yourdomain.com/privkey.pem
        SSLCertificateChainFile /etc/letsencrypt/live/yourdomain.com/fullchain.pem

        <Directory /var/www/sub-domains/com.yourdomain.www/html>
                Options -ExecCGI -Indexes
                AllowOverride None

                Order deny,allow
                Deny from all
                Allow from all

                Satisfy all
        </Directory>
</VirtualHost>
```

Here's what's happening above. You may want to review the [Apache Web Server Multi-Site Setup](../web/apache-sites-enabled.md) to see the differences in the application of an SSL purchased from another provider and the Let's Encrypt certificate:

* Even though port 80 (standard http) is listening, we are redirecting all traffic to port 443 (https)
* SSLEngine on - simply says to use SSL
* SSLProtocol all -SSLv2 -SSLv3 -TLSv1 - says to use available protocols, except those found to have vulnerabilities. You should research periodically which protocols are currently acceptable for use.
* SSLHonorCipherOrder on - this deals with the next line regarding the cipher suites, and says to deal with them in the order that they are given. This is another area where you should review the cipher suites that you want to include periodically
* SSLCertificateFile - this is the PEM file, that contains the site certificate **AND** the intermediate certificate. We still need the 'SSLCertificateChainFile' line in our configuration, but it will simply specify the same PEM file again.
* SSLCertificateKeyFile - the PEM file for the private key, generated with the _certbot_ request.
* SSLCertificateChainFile - the certificate from your certificate provider, often called the intermediate certificate, in this case exactly like the 'SSLCertificateFile' location above.

Once you have made all of your changes, simply restart _httpd_ and if it starts test your site to make sure you now have a valid certificate file showing. If so, you are ready to move on to the next step: automation.

## Using _certbot_ With Nginx

A quick note: using _certbot_ with Nginx is pretty much the same as with Apache. Here's the short, short version of the guide:

Run this command to get started:

```bash
certbot --nginx
```

You will need to enter your email address and the site you want a certificate for. Assuming you have at least one site configured (with a domain name pointing at the server), you'll see a list like this:

```
1. yourwebsite.com
2. subdomain.yourwebsite.com
```

If you have multiple sites, press the number that corresponds to the site you want a certificate for.

The rest of the text is similar to what is above. The results will be a bit different. If you have an Nginx configuration file that looks like this:

```
server {
    server_name yourwebsite.com;

    listen 80;
	listen [::]:80;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
}

```

After _certbot_ gets through with it, it'll look like a bit this:

```
server {
    server_name  yourwebsite.com;

    listen 443 ssl; # managed by Certbot
    listen [::]:443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/yourwebsite.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/yourwebsite.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
}

server {
    if ($host = yourwebsite.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


  listen 80;
  listen [::]:80;
  server_name yourwebsite.com;
    return 404; # managed by Certbot
}
```

Depending on a couple of things (for example, if you're using Nginx as a reverse proxy), you may need to dive into the new configuration file to fix up a few things that _certbot_ won't handle perfectly on its own.

Or write your own configuration file the hard way.
## Automating Let's Encrypt Certificate Renewal

The beauty of installing _certbot_ is that the Let's Encrypt certificate will be automatically renewed. There is no need to create a process to do this. We do need to test the renewal with:

```bash
certbot renew --dry-run
```

When you run this command, you'll get a nice output showing the renewal process:

```
Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Processing /etc/letsencrypt/renewal/yourdomain.com.conf
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Cert not due for renewal, but simulating renewal for dry run
Plugins selected: Authenticator apache, Installer apache
Account registered.
Simulating renewal of an existing certificate for yourdomain.com
Performing the following challenges:
http-01 challenge for yourdomain.com
Waiting for verification...
Cleaning up challenges

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
new certificate deployed with reload of apache server; fullchain is
/etc/letsencrypt/live/yourdomain.com/fullchain.pem
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Congratulations, all simulated renewals succeeded:
  /etc/letsencrypt/live/yourdomain.com/fullchain.pem (success)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```

The command to renew _certbot_ can be found using one of the following methods:

* By listing the contents of `/etc/crontab/`
* By listing the contents of `/etc/cron.*/*`
* By running `systemctl list-timers`

In this example, we are using the last option and we can see that _certbot_ exists and that it was installed with the `snap` procedure:

```bash
sudo systemctl list-timers
Sat 2021-04-03 07:12:00 UTC  14h left   n/a                          n/a          snap.certbot.renew.timer     snap.certbot.renew.service
```

## Conclusions

Let's Encrypt SSL certificates are yet another option for securing your web site with an SSL. Once installed, the system provides automatic renewal of certificates and will encrypt traffic to your web site.

It should be noted that Let's Encrypt certificates are used for standard DV (Domain Validation) certificates. They cannot be used for OV (Organization Validation) or EV (Extended Validation) certificates.
