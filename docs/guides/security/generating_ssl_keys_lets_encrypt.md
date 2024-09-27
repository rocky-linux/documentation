---
title: Generating SSL Keys - Let's Encrypt
author: Steven Spencer
contributors: wsoyinka, Antoine Le Morvan, Ezequiel Bruni, Andrew Thiesen, Ganna Zhyrnova
tested*with: 8.5
tags:
  - security
  - ssl
  - certbot
---

## Prerequisites & assumptions

- Comfort with the command line
- Familiarity with securing web sites with SSL certificates is a plus
- Knowledge of command line text editors (this example uses *vi*)
- A web server open to the world and running on port 80 (`http`)
- Familiarity with *SSH* (secure shell) and the ability to access your server with *SSH*
- All commands assume that you are the root user or that you have used `sudo` to gain root access

## Introduction

One of the most popular ways to secure a web site is with Let's Encrypt SSL certificates, which are also free.

These are actual certificates, not self-signed or snake oil, so they are great for a low-budget security solution. This document will walk you through the process of installing and using Let's Encrypt certificates on a Rocky Linux web server.

## Installation

To do the next steps, use `ssh` to log into your server. If your server's fully qualified DNS name was <www.myhost.com>, then you would use:

```bash
ssh -l root www.myhost.com
```

Or, if you must access your server as an unprivileged user first. Use your username:

```bash
ssh -l username www.myhost.com
```

Then:

```bash
sudo -s
```

You will need your user's credentials in this case to gain access to the system as root.

Let's Encrypt uses a package called *certbot* that you install with the EPEL repository. Add those first:

```bash
dnf install epel-release
```

Install the appropriate packages, depending on whether you use Apache or Nginx as your web server. For Apache that is:

```bash
dnf install certbot python3-certbot-apache
```

For Nginx, just change out one package:

```bash
dnf install certbot python3-certbot-nginx
```

You can always install both server modules if necessary.

!!! Note

    An earlier version of this guide required the snap package version of *certbot*, which was necessary at the time. The RPM versions have been re-tested recently, and are working now. That said, Certbot strongly recommends the use of the [snap install procedure](https://certbot.eff.org/instructions?ws=apache&os=centosrhel8). Rocky Linux 8 and 9 have *certbot* available in the EPEL, so we show that procedure here. If you would like to use the procedure recommended by Certbot, just follow that procedure instead.

## Getting the Let's Encrypt Certificate for the Apache server

You can retrieve your Let's Encrypt certificate in two ways: Using the command to change the `http` configuration file for you, or retrieving the certificate only. If you are using the procedure for a multi-site setup suggested for one or more sites in the procedure [Apache Web Server Multi-Site Setup](../web/apache-sites-enabled.md), then just retrieve your certificate.

The multi-site setup is the assumption here, so the instructions that follow will only retrieve the certificate. If you are running a standalone web server with the default configuration, you can retrieve the certificate and change the configuration file in one step:

```bash
certbot --apache
```

That is really the easiest way to get things done. However, sometimes you want to take a more manual approach and grab the certificate. To retrieve the certificate only, use this command:

```bash
certbot certonly --apache
```

These commands will generate a set of prompts you need to answer. The first is to give an email address for important information:

```bash
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator apache, Installer apache
Enter email address (used for urgent renewal and security notices)
 (Enter 'c' to cancel): yourusername@youremaildomain.com
```

The next asks you to read and accept the terms of the subscriber agreement. When you have read the agreement answer 'Y' to continue:

```bash
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please read the Terms of Service at
https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf. You must
agree in order to register with the ACME server. Do you agree?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o:
```

The next is a request to share your email with the Electronic Frontier Foundation. Answer 'Y' or 'N' as is your preference:

```bash
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Would you be willing, once your first certificate is successfully issued, to
share your email address with the Electronic Frontier Foundation, a founding
partner of the Let's Encrypt project and the non-profit organization that
develops Certbot? We'd like to send you email about our work encrypting the web,
EFF news, campaigns, and ways to support digital freedom.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o:
```

The next prompt asks you to identify the domain you want the certificate for. It may show a domain in the listing based on your running web server. If so, enter the number next to the domain that you are getting the certificate for. In this case, only one option ('1') exists:

```bash
Which names would you like to activate HTTPS for?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: your-server-hostname
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate numbers separated by commas and/or spaces, or leave input
blank to select all options shown (Enter 'c' to cancel):
```

If all goes well, you will receive the following message:

```bash
Requesting a certificate for your-server-hostname
Performing the following challenges:
http-01 challenge for your-server-hostname
Waiting for verification...
Cleaning up challenges
Subscribe to the EFF mailing list (email: yourusername@youremaildomain.com).

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/your-server-hostname/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/your-server-hostname/privkey.pem
   Your certificate will expire on 2021-07-01. To obtain a new or
   tweaked version of this certificate in the future, simply run
   certbot again. To non-interactively renew *all* of your
   certificates, run "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le
```

## The site configuration - `https`

Applying the configuration file to our site is nearly identical to the procedure used for a purchased SSL certificate from another provider.

A single PEM (Privacy Enhanced Mail) file includes the certificate and chain file. This is a common format for all certificate files now. Even though it has "Mail" in the reference, it is just a type of certificate file. An illustration of the configuration file follows, and a description of what is happening:

!!! info

    Previously, this documentation contained a line in the configuration for the `SSLCertificateChainFile` directive. Since Apache version 2.4.8, that directive is deprecated as the `SSLCertificateFile` directive [now extends to include the intermediate CA file](https://httpd.apache.org/docs/2.4/mod/mod_ssl.html#sslcertificatechainfile).

```bash
<VirtualHost *:80>
        ServerName your-server-hostname
        ServerAdmin username@rockylinux.org
        Redirect / https://your-server-hostname/
</VirtualHost>
<Virtual Host *:443>
        ServerName your-server-hostname
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

        SSLCertificateFile /etc/letsencrypt/live/your-server-hostname/fullchain.pem
        SSLCertificateKeyFile /etc/letsencrypt/live/your-server-hostname/privkey.pem

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

Here is what is happening:

- Even though port 80 (standard `http`) is listening, you are redirecting all traffic to port 443 (`https`)
- SSLEngine on - says to use SSL
- SSLProtocol all -SSLv2 -SSLv3 -TLSv1 - says to use available protocols, except those found to have vulnerabilities. You need to periodically research the protocols that are currently acceptable for use.
- SSLHonorCipherOrder on - this deals with the next line regarding the cipher suites, and says to deal with them in the order listed. This is another area where you need to review the cipher suites that you want to include periodically
- SSLCertificateFile - this is the PEM file, and includes the site certificate **AND** the intermediate certificate.
- SSLCertificateKeyFile - the PEM file for the private key, generated with the *certbot* request.

When you have made all of your changes, restart *httpd* and if it starts test your site to ensure you now have a valid certificate file showing. If so, you are ready to move on to the next step: automation.

## Using *certbot* With Nginx

A quick note: using *certbot* with Nginx is pretty much the same as with Apache. Here is the short version of the guide:

Run this command to get started:

```bash
certbot --nginx
```

You will need to enter your email address and the site you want a certificate for. Assuming you have at least one site configured (with a domain name pointing at the server), you will see a list:

```bash
1. yourwebsite.com
2. subdomain.yourwebsite.com
```

If you have multiple sites, press the number that corresponds to the site you want a certificate for.

The rest of the text is similar to what is above. The results will be a bit different. If you have an Nginx configuration file that looks like this:

```bash
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

After *certbot* gets through with it, it will look like a bit this:

```bash
server {
    server*name  yourwebsite.com;

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

If you are using Nginx as a reverse proxy, you may need to change the new configuration file to fix up a few things that *certbot* will not handle perfectly on its own.

## Automating Let's Encrypt certificate renewal

!!! note

    Replace occurences with "your-server-hostname" in these examples, with the actual domain name or hostname.

The beauty of installing *certbot* is that the Let's Encrypt certificate will be automatically renewed. You need not create a process to do this. You *do* need to test the renewal with:

```bash
certbot renew --dry-run
```

When you run this command, you will get a nice output showing the renewal process:

```bash
Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Processing /etc/letsencrypt/renewal/your-server-hostname.conf
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Cert not due for renewal, but simulating renewal for dry run
Plugins selected: Authenticator apache, Installer apache
Account registered.
Simulating renewal of an existing certificate for your-server-hostname
Performing the following challenges:
http-01 challenge for your-server-hostname
Waiting for verification...
Cleaning up challenges

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
new certificate deployed with reload of apache server; fullchain is
/etc/letsencrypt/live/your-server-hostname/fullchain.pem
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Congratulations, all simulated renewals succeeded:
  /etc/letsencrypt/live/your-server-hostname/fullchain.pem (success)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```

You can renew the *certbot* certificate in one of the following ways:

- By listing the contents of `/etc/crontab/`
- By listing the contents of `/etc/cron.*/*`
- By running `systemctl list-timers`

Using the `systemctl list-timers` method, you can see that *certbot* exists and its installation was with the `snap` procedure:

```bash
sudo systemctl list-timers
Sat 2021-04-03 07:12:00 UTC  14h left   n/a                          n/a          snap.certbot.renew.timer     snap.certbot.renew.service
```

## Conclusions

Let's Encrypt SSL certificates are yet another option for securing your web site with an SSL. Once installed, the system provides automatic renewal of certificates and will encrypt traffic to your web site.

Let's Encrypt certificates are for standard DV (Domain Validation) certificates. Using them for OV (Organization Validation) or EV (Extended Validation) certificates is not possible.
