# Generating SSL Keys - Let's Encrypt

## Prerequisites

* Comfort with the command line
* Familiarity with securing web sites with SSL certificates is a plus
* Knowledge of command line text editors (this example uses _vi_)
* An already running web server open to the world on port 80 (http)
* Familiarity with _ssh_ (secure shell) and the ability to access your server with _ssh_

# Introduction

One of the most popular ways to secure a web site, currently, is using Let's Encrypt SSL certificates, which are also free. 

These are actual certificates, not self-signed or snake oil, etc., so they are great for a low-budget security solution. This document will walk you through the process of installing and using Let's Encrypt certificates on a Rocky Linux web server.

## Assumptions

* All commands assume that you are either the root user or that you have used _sudo_ to gain root access.

## Installation 

To do the next steps, use _ssh_ to log into your server. If your server's fully qualified DNS name was www.myhost.com, then you would use:

`ssh -l root www.myhost.com` 

Or, if you must access your server as an unprivileged user first. Use your username:

`ssh -l username www.myhost.com`

And then:

`sudo -s`

You will need your _sudo_ user's credentials in this case to gain access to the system as root.

Let's Encrypt uses a package called _certbot_ which needs to be installed via a snap package. To install _snapd_ on Rocky Linux, you will need to install the EPEL repository if you have not done so already:

`dnf install epel-release`

Besides _snapd_ you may also need _fuse_ and _squashfuse_ depending on your system. We also need to make sure that _mod\_ssl_ is installed. To install them all use:

`dnf install snapd fuse squashfuse mod_ssl`

_snapd_ requires a bunch of dependencies that will install along with it, so answer yes to the installation prompt.

Once _snapd_  and all of the dependencies are installed, enable the _snapd_ service with:

`systemctl enable --now snapd.socket`

_certbot_ requires classic _snapd_ support, so we need to enable that with a symbolic link: 

`ln -s /var/lib/snapd/snap /snap`

Before continuing on, we want to make sure that all of the snap packages are up to date. To do this use: 

`snap install core; snap refresh core`

If there are any updates, they will install here.

Just in case you got ahead of yourself and installed _certbot_ from the RPM (which will not work, by the way), make sure that you remove it with: 

`dnf remove certbot`

And finally, it's time to install _certbot_ with:

`snap install --classic certbot`

This should install _certbot_. The final step is to put the _certbot_ command in a path that Rocky Linux can find easily. This is done with another symbolic link:

`ln -s /snap/bin/certbot /usr/bin/certbot`

## Getting The Let's Encrypt Certificate

There are two ways to retrieve your Let's Encrypt certificate, either using the command to modify the http configuration file for you, or to just retrieve the certificate. If you are using the procedure for a multi-site setup suggested for one or more sites in the procedure [Apache Web Server Multi-Site Setup](apache-sites-enabled.md), then you will only want to retrieve your certificate. 

We are assuming that you **are** using this procedure so we will only retrieve the certificate. If you are running a standalone web server using the default configuration, you can retrieve the certificate and modify the configuration file in one step using `certbot --apache`. 

To retrieve the certificate only, use this command:

`certbot certonly --apache`

This will generate a set of prompts that you will need to answer. The first is to give an email address for important information:

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

The next prompt asks you which domain you want the certificate for. It should display a domain in the listing based on your running web server. If so, enter the number next to the domain that you are getting the certificate for. In this case there is only one option ('1'):

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

Applying the configuration file to our site is slightly different than if we were using a purchased SSL certificate from another provider. 

The certificate and chain file are included in a single PEM (Privacy Enhanced Mail) file. This is a common format for all certificate files now, so even though it has "Mail" in the reference, it is just a type of certificate file. To illustrate the configuration file, we will show it in it's entirety and then describe what is happening:

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

Here's what's happening above. You may want to review the [Apache Web Server Multi-Site Setup](apache-sites-enabled.md) to see the differences in the application of an SSL purchased from another provider and the Let's Encrypt certificate:

* Even though port 80 (standard http) is listening, we are redirecting all traffic to port 443 (https)
* SSLEngine on - simply says to use SSL
* SSLProtocol all -SSLv2 -SSLv3 -TLSv1 - says to use all available protocols, except those that have been found to have vulnerabilities. You should research periodically which protocols are currently acceptable for use.
* SSLHonorCipherOrder on - this deals with the next line that regarding the cipher suites, and says to deal with them in the order that they are given. This is another area where you should review the cipher suites that you want to include periodically
* SSLCertificateFile - this is the PEM file, that contains the site certificate **AND** the intermediate certificate. We still need the 'SSLCertificateChainFile' line in our configuration, but it will simply specify the same PEM file again.
* SSLCertificateKeyFile - the PEM file for the private key, generated with the _certbot_ request.
* SSLCertificateChainFile - the certificate from your certificate provider, often called the intermediate certificate, in this case exactly like the 'SSLCertificateFile' location above.

Once you have made all of your changes, simply restart _httpd_ and if it starts test your site to make sure you now have a valid certificate file showing. If so, you are ready to move on to the next step.

## Automating Let's Encrypt Certificate Renewal

The beauty of installing _certbot_ is that the Let's Encrypt certificate will be automatically renewed. There is no need to create a process to do this. We do need to test the renewal with:

`certbot renew --dry-run`

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

The [_certbot_ documentation](https://certbot.eff.org/lets-encrypt/centosrhel8-apache.html) tells you in their step number 8, that the automatic renewal process could be in a couple of different spots, depending on your system. For a Rocky Linux install, you are going to find the process by using:

`systemctl list-timers`

Which gives you a list of processes, one of which will be for _certbot_:

```
Sat 2021-04-03 07:12:00 UTC  14h left   n/a                          n/a          snap.certbot.renew.timer     snap.certbot.renew.service
```

# Conclusions

Let's Encrypt SSL certificates are yet another option for securing your web site with an SSL. Once installed, the system provides automatic renewal of certificates and will encrypt traffic to your web site. 

It should be noted that Let's Encrypt certificates are used for standard DV (Domain Validation) certificates. They cannot be used for OV (Organization Validation) or EV (Extended Validation) certificates. 
