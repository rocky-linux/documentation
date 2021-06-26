# Apache Web Server Multi-Site Setup

## What You Need
* A server running Rocky Linux
* Knowledge of the command-line and text editors (This example uses *vi*, but can be adapted to your favorite editor.)
    * If you'd like to learn about the vi text editor, [here's a handy tutorial](https://www.tutorialspoint.com/unix/unix-vi-editor.htm).
* Basic knowledge about installing and running web services

# Apache Web Server Multi-Site Setup

Rocky Linux has many ways for you to set up a website. One way is using Apache, which is for a multi-site setup on a single server. While this method is for multi-site servers, it can also act as a base configuration for a single-site webserver. 

Historical Fact: This server setup appears to have started with Debian-based systems, but it is perfectly adaptable to any Linux OS running Apache.

## Install Apache
You will likely need other packages for your website. PHP will almost certainly be required, and you will also need a database package. Installing PHP and httpd (Apache) will get you the latest version of both from the Rocky Linux repositories. 

You may need httpd modules as well, such as php-bcmath or php-mysqlind. Your web application specifications should detail what is required. After httpd, modules are installed or activated if they already exist. For now, we will install httpd and PHP, as those are the initial requirements:

* From the command-line run `dnf install httpd php`

## Add Extra Directories

This method uses a couple of additional directories, but they don't currently exist on the system. We need to add two directories in */etc/httpd/* called "sites-available" and "sites-enabled."

* From the command-line type `mkdir /etc/httpd/sites-available` and then `mkdir /etc/httpd/sites-enabled`

* We also need a directory where our sites are going to reside. The directory can be anywhere, but a good way to keep things organized is to create a directory called sub-domains. To keep things simple, put this in /var/www: `mkdir /var/www/sub-domains/`

## Configuration
We also need to add a line to the very bottom of the httpd.conf file. To do this, type `vi /etc/httpd/conf/httpd.conf` and go to the bottom of the file and add `Include /etc/httpd/sites-enabled`.

Our actual configuration files will reside in */etc/httpd/sites-available* and we will simply symlink to them in */etc/httpd/sites-enabled*. 

**Why do we do this?**
The reason here is simple. Say you have ten websites all running on the same server with different IP addresses. Say that site B has some significant updates, and you have to make changes to the configuration for that site. Also, there is something wrong with the changes made, so when you restart httpd to read in the new changes, httpd doesn't start.

The site you are working on not start, and the other sites also will not. With this method, you can remove the symbolic link for the website that caused the failure and restart httpd. It’ll start working again, and you can go to work, trying to fix the broken site configuration. 

It sure takes the pressure off, knowing that the phone will not ring with some angry customer or an angry boss because a service is off-line.

### The Site Configuration
The other benefit of this method is that it allows us to specify everything outside of the default httpd.conf file. Let the default httpd.conf load with the defaults and let your site configurations do everything else. It also makes it very easy to troubleshoot a broken site configuration. 

Now, say you have a website that loads a wiki. It requires a configuration file, which makes the site available via port '80'.

If you want to serve the website with SSL; as most websites should be doing by now. Then you must add another (nearly identical) section to the httpd configuration file to enable port 443.

You can take a look at that below in the [Configuration https - Using An SSL Certificate](#https) section.

So we first need to create this configuration file in *sites-available*: `vi /etc/httpd/sites-available/com.wiki.www`

The configuration file configuration content would look something like this:

```apache
<VirtualHost *:80>
        ServerName www.ourownwiki.com 
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/com.ourownwiki.www/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/
        # ScriptAlias /cgi-bin/ /var/www/sub-domains/com.ourownwiki.www/cgi-bin/

	CustomLog "/var/log/httpd/com.ourownwiki.www-access_log" combined
	ErrorLog  "/var/log/httpd/com.ourownwiki.www-error_log"

        <Directory /var/www/sub-domains/com.ourownwiki.www/html>
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

In our example above, the wiki site loads from the HTML sub-directory of _com.ourownwiki.www_, which means that the path we created in _/var/www_ (above) will need some additional directories to satisfy this:

`mkdir -p /var/www/sub-domains/com.ourownwiki.www/html`

These directories will create the entire path with a single command. Then we would want to install our files to this directory which will run the website. It could be something you made yourself or an installable web application (in this case, a wiki that you downloaded).

Copy your files to the path above:

`cp -Rf wiki_source/* /var/www/sub-domains/com.ourownwiki.www/html/`

## <a name="https"></a>Configuration https - Using an SSL Certificate

As stated earlier, every web server created these days _should_ be running with SSL (AKA the secure socket layer). 

This process starts by generating a private key and a CSR (which stands for certificate signing request) and then submitting the CSR to the certificate authority to purchase the SSL certificate. The process of generating these keys is somewhat extensive, and it has its documentation. 

If you are new to generating keys for SSL, please take a look at: [Generating SSL Keys](ssl_keys_https.md)

You can also use this alternate process for using an [SSL certificate from Let's Encrypt](generating_ssl_keys_lets_encrypt.md)

### Placement of the SSL keys and Certificate's

Now that you have your keys and certificate files, we need to place them logically in your file system on the webserver. As we have seen with the example configuration file (above), we are placing our web files in _/var/www/sub-domains/com.ourownwiki.www/html_. 

We want to place our certificate and Key files associated with the domain, but NOT in the document root (which is the _html_ folder). 

We never want our certificates and keys to potentially be exposed to the Internet or External Network. That would expose our server to serious risk.

Instead, we will create a new directory structure for our SSL files outside of the document root:

`mkdir -p /var/www/sub-domains/com.ourownwiki.www/ssl/{ssl.key,ssl.crt,ssl.csr}`

If you are new to the "tree" syntax for making directories, what the above means is:

"Make a directory called ssl and then make three directories inside of that called ssl.key, ssl.crt, and ssl.csr."

The CSR File does not have to be in the Directory Tree of the webserver.

If you ever need to re-issue the certificate from a different provider, etcetera, it is a good idea to have a stored copy of the CSR file. The question is where to store it to remember; keeping it within your websites' tree is logical. 

Assuming that you have named your key, CSR, and crt (certificate) files with the name of your website and that you have them stored in _/root_, we will then copy them to their respective locations that we just created:

```
cp /root/com.wiki.www.key /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.key/
cp /root/com.wiki.www.csr /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.csr/
cp /root/com.wiki.www.crt /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.crt/
```

### The Site Configuration - https

Once you have generated your keys and purchased the SSL Certificate, you can now move forward with the website's configuration using the new keys. 

To start with, break down the beginning of the configuration file. For instance, even though we still want to listen on port 80 (standard HTTP) for incoming requests, we don't want any of those requests to go to port 80. We want them to go to port 443 (or HTTP secure, better known as SSL). Our port 80 configuration section will be minimal:
```
<VirtualHost *:80>
        ServerName www.ourownwiki.com 
        ServerAdmin username@rockylinux.org
        Redirect / https://www.ourownwiki.com/
</VirtualHost>
```

What this says is to send any regular web request to the HTTPS configuration instead. We can change the Apache "Redirect" option shown above to "Redirect Permanent" once all testing is complete and you can see that the site operates as you want it. The "Redirect" we have chosen is temporary.

Search Engines will learn the Permanent Redirect. Then any traffic to your site that comes from search engines will go only to port 443 (HTTPS) without hitting port 80 (HTTP) first.

Next, we need to define the HTTPS portion of the configuration file. The HTTP section is duplicated here for clarity to show that this all happens in the same configuration file:

```
<VirtualHost *:80>
        ServerName www.ourownwiki.com 
        ServerAdmin username@rockylinux.org
        Redirect / https://www.ourownwiki.com/
</VirtualHost>
<Virtual Host *:443>
        ServerName www.ourownwiki.com 
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/com.ourownwiki.www/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/
        # ScriptAlias /cgi-bin/ /var/www/sub-domains/com.ourownwiki.www/cgi-bin/

	CustomLog "/var/log/httpd/com.ourownwiki.www-access_log" combined
	ErrorLog  "/var/log/httpd/com.ourownwiki.www-error_log"

        SSLEngine on
        SSLProtocol all -SSLv2 -SSLv3 -TLSv1
        SSLHonorCipherOrder on
        SSLCipherSuite EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384
:EECDH+aRSA+SHA256:EECDH+aRSA+RC4:EECDH:EDH+aRSA:RC4:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS

        SSLCertificateFile /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.crt/com.wiki.www.crt
        SSLCertificateKeyFile /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.key/com.wiki.www.key
        SSLCertificateChainFile /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.crt/your_providers_intermediate_certificate.crt

        <Directory /var/www/sub-domains/com.ourownwiki.www/html>
                Options -ExecCGI -Indexes
                AllowOverride None

                Order deny,allow
                Deny from all
                Allow from all

                Satisfy all
        </Directory>
</VirtualHost>
```

So, breaking down this configuration further, after the normal portions of the layout and down to the SSL portion:

* SSLEngine on - Says to use SSL.
* SSLProtocol all -SSLv2 -SSLv3 -TLSv1 - Says to use all available protocols, except those that are found to have vulnerabilities. It would be best if you researched in an ongoing manner which protocols are currently acceptable for use.
* SSLHonorCipherOrder on - This deals with the following line regarding the cipher suites and says to deal with them in their given order. Also, you should review the cipher suites that you want to include periodically.
* SSLCertificateFile - Is the newly purchased and applied certificate file and its location.
* SSLCertificateKeyFile - The key you generated when creating your certificate signing request.
* SSLCertificateChainFile - The certificate from your certificate provider, often referred to as the intermediate certificate.
Next, take everything live and if there are no errors starting the web service and if going to your web site reveals https without errors, then you are ready to go.

## Taking It Live

The *httpd.conf* file is including */etc/httpd/sites-enabled* at the very end of the file. Then when httpd restarts, it will load whatever configuration files are in that *sites-enabled* directory. For this purpose, all of our configuration files are in *sites-available*. 

By design so that we can easily remove things if httpd fails to restart. We enable our configuration file. Then need to create a symbolic link to that file in *sites-enabled*. And then start or restart the web service. To do this, we use this command:

`ln -s /etc/httpd/sites-available/com.ourownwiki.www /etc/httpd/sites-enabled/`

The above will create the link to the configuration file in *sites-enabled*, just as we want.

Now start the httpd service with `systemctl to start httpd`. Or restart it if it is already running with: `systemctl restart httpd`, and assuming the web service restarts, you can now go and do some testing on your new site.

