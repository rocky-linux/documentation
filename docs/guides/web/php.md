---
title: PHP and PHP-FPM
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova, Joseph Brinkman
tested_with: 9.3, 8.9
tags:
  - web
  - php
  - php-fpm
---

# PHP and PHP-FPM

**PHP** (**P**HP **H**ypertext **P**reprocessor) is a source scripting language specially designed for web application development. In 2024, PHP represented a little less than 80% of the web pages generated in the world. PHP is open-source and is the core of the most famous CMS (WordPress, Drupal, Joomla!, Magento, ...).

**PHP-FPM** (**F**astCGI **P**rocess **M**anager) is integrated to PHP since its version 5.3.3. The FastCGI version of PHP brings additional functionalities.

## Generalities

**CGI** (**C**ommon **G**ateway **I**nterface) and **FastCGI** allow communication between the web server (Apache, Nginx, ...) and a development language (PHP, Python, Java):

* In the case of **CGI**, each request creates a **new process**, which is less efficient in performance.
* **FastCGI** relies on a **certain number of processes** to treat its client requests.

PHP-FPM, **in addition to better performances**, brings:

* The possibility of better **partitioning the applications**: launching processes with different uid/gid, with personalized `php.ini` files,
* The management of the statistics,
* Log management,
* Dynamic management of processes and restart without service interruption ('graceful').

!!! Note

    Since Apache has a PHP module, php-fpm is more commonly used on an Nginx server.

## Choose a PHP version

Rocky Linux, like its upstream, offers many versions of the language. Some of them have reached the end of their life but are kept to continue hosting historical applications that are not yet compatible with new versions of PHP. Please refer to the [supported versions](https://www.php.net/supported-versions.php) page of the php.net website to choose a supported version.

To obtain a list of available versions, enter the following command:

=== "9.3 PHP module list"

	```bash
	$ sudo dnf module list php

	Rocky Linux 9 - AppStream
	Name                                                 Stream                                                  Profiles                                                                   Summary                                                         
	php                                                  8.1 [d]                                                 common [d], devel, minimal                                 

	Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
	```

	The Remi repository offers more recent releases of PHP than the Appstream repository, including versions 8.2 and 8.3. 

	To install the Remi repository, run the following command:

	```bash
	sudo dnf install https://rpms.remirepo.net/enterprise/remi-release-9.rpm
	```

	Once the Remi repository is installed, enable it by running the following command.

	```bash
	sudo dnf config-manager --set-enabled remi
	```

	You can now activate a newer module (PHP 8.3) by entering the following command:

	```bash
	sudo dnf module enable php:remi-8.3
	```

=== "8.9 PHP module list"

	```bash
	$ sudo dnf module list php

	Rocky Linux 8 - AppStream
	Name                                                 Stream                                                  Profiles                                                                   Summary                                                         
	php                                                  7.2 [d]                                                 common [d], devel, minimal                                                 PHP scripting language                                          
	php                                                  7.3                                                     common [d], devel, minimal                                                 PHP scripting language                                          
	php                                                  7.4                                                     common [d], devel, minimal                                                 PHP scripting language                                          
	php                                                  8.0                                                     common [d], devel, minimal                                                 PHP scripting language                                          

	Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
	```

	Rocky provides different PHP modules from its AppStream repository.

	You will note that the default version of a Rocky 8.9 is 7.2 that has already reached its end of life at the time of writing.

	You can activate a newer module by entering the following command:

	```bash
	sudo dnf module enable php:8.0
	==============================================================================================
	Package               Architecture         Version               Repository             Size
	==============================================================================================
	Enabling module streams:
	httpd                                      2.4                                                                                                                              
	nginx                                      1.14                                                                                                                             
	php                                        8.0                                                                                                                              

	Transaction Summary
	==============================================================================================

	Is this ok [y/N]:

	Transaction Summary
	==============================================================================================

	Is this ok [y/N]: y
	Complete!
	```

You can now proceed to the installation of the PHP engine.

## PHP cgi mode

First, let's see how to install and use PHP in CGI mode. We can only make it work with the Apache web server and its `mod_php` module. We will see, later in this document, in the FastCGI part (php-fpm) how to integrate PHP in Nginx (but also Apache).

### Installation

The installation of PHP is relatively trivial since it consists of installing the main package and the few modules you will need.

The example below installs PHP with the modules usually installed with it.

=== "9.3 install PHP"

	```bash
	sudo dnf install php php-cli php-gd php-curl php-zip php-mbstring
	```
	
	You will be prompted to import GPG keys for the epel9 (Extra Packages for Enterprise Linux 9) and Remi repositories during installation. Enter y to import the keys:

	```bash
	Extra Packages for Enterprise Linux 9 - x86_64                                                                        
	Importing GPG key 0x3228467C:
	Userid     : "Fedora (epel9) <epel@fedoraproject.org>"
	Fingerprint: FF8A D134 4597 106E CE81 3B91 8A38 72BF 3228 467C
	From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-9
	Is this ok [y/N]: y
	Key imported successfully
	Remi's RPM repository for Enterprise Linux 9 - x86_64                                                         
	Importing GPG key 0x478F8947:
	Userid     : "Remi's RPM repository (https://rpms.remirepo.net/) <remi@remirepo.net>"
	Fingerprint: B1AB F71E 14C9 D748 97E1 98A8 B195 27F1 478F 8947
	From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-remi.el9
	Is this ok [y/N]: y
	Key imported successfully
	Running transaction check
	Transaction check succeeded.
	Running transaction test
	Transaction test succeeded.

	Complete!
	```

=== "8.9 install PHP"

	```bash
	sudo dnf install php php-cli php-gd php-curl php-zip php-mbstring
	```

You can check that the installed version corresponds to the expected one:

=== "9.3 check PHP version"

	```bash
	$ php -v
	PHP 8.3.2 (cli) (built: Jan 16 2024 13:46:41) (NTS gcc x86_64)
	Copyright (c) The PHP Group
	Zend Engine v4.3.2, Copyright (c) Zend Technologies
	with Zend OPcache v8.3.2, Copyright (c), by Zend Technologies
	```

=== "8.9 check PHP version"

	```bash
	$ php -v
	PHP 7.4.19 (cli) (built: May  4 2021 11:06:37) ( NTS )
	Copyright (c) The PHP Group
	Zend Engine v3.4.0, Copyright (c) Zend Technologies
	with Zend OPcache v7.4.19, Copyright (c), by Zend Technologies
	```

### Configuration

#### Apache integration

To serve PHP pages in CGI mode, you must install the Apache server, configure it, activate it, and start it.

* Installation:

	```bash
	sudo dnf install httpd
	```

	* Activation:

	```bash
	sudo systemctl enable --now httpd
	sudo systemctl status httpd
	```

* Don't forget to configure the firewall:

	```bash
	sudo firewall-cmd --add-service=http --permanent
	sudo firewall-cmd --reload
	```

The default vhost should work out of the box. PHP provides a `phpinfo()` function that generates a summary table of its configuration. It's very useful to test the good working of PHP. However, be careful not to leave such test files on your servers. They represent a huge security risk for your infrastructure.

Create the file `/var/www/html/info.php` (`/var/www/html` being the default vhost directory of the default Apache configuration):

```bash
<?php
phpinfo();
?>
```

Use a web browser to check that the server works properly by going to the page [http://your-server-ip/info.php](http://your-server-ip/info.php).

!!! Warning

    Do not leave the info.php file on your server!

## PHP-FPM (FastCGI)

As we highlighted earlier in this document, there are many advantages to switching web hosting to PHP-FPM mode.

### Installation

The installation is limited to the php-fpm package:

```bash
sudo dnf install php-fpm
```

As php-fpm is a service from a system point of view, it must be activated and started:

```bash
sudo systemctl enable --now php-fpm
sudo systemctl status php-fpm
```

### Configuration

The main configuration file is stored under `/etc/php-fpm.conf`.

```bash
include=/etc/php-fpm.d/*.conf
[global]
pid = /run/php-fpm/php-fpm.pid
error_log = /var/log/php-fpm/error.log
daemonize = yes
```

!!! Note

    The php-fpm configuration files are widely commented on. Go and have a look!

As you can see, the files in the `/etc/php-fpm.d/` directory with the `.conf` extension are always included.

By default, a PHP process pool, named `www`, is declared in `/etc/php-fpm.d/www.conf`.

```bash
[www]
user = apache
group = apache

listen = /run/php-fpm/www.sock
listen.acl_users = apache,nginx
listen.allowed_clients = 127.0.0.1

pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35

slowlog = /var/log/php-fpm/www-slow.log

php_admin_value[error_log] = /var/log/php-fpm/www-error.log
php_admin_flag[log_errors] = on
php_value[session.save_handler] = files
php_value[session.save_path]    = /var/lib/php/session
php_value[soap.wsdl_cache_dir]  = /var/lib/php/wsdlcache
```

| Instructions | Description                                                   |
|--------------|---------------------------------------------------------------|
| `[pool]`     | Process pool name. The configuration file can comprise several process pools (the pool's name in brackets starts a new section). |
| `listen`     | Defines the listening interface or the Unix socket used. |

#### Configuring the way to access php-fpm processes

There are 2 ways to connect.

Via an inet interface such as:

`listen = 127.0.0.1:9000`.

Or via a Unix socket:

`listen = /run/php-fpm/www.sock`.

!!! Note

    Using a socket when the web server and PHP server are on the same machine removes the TCP/IP layer and optimizes the performance.

When working via an interface, you have to configure `listen.owner`, `listen.group`, `listen.mode` to specify the owner, the owner group and the rights of the Unix socket. **Warning:** Both servers (web and PHP) must have access rights on the socket.

When working via a socket, you must configure `listen.allowed_clients` to restrict access to the PHP server to certain IP addresses.

Example: `listen.allowed_clients = 127.0.0.1`

#### Static or dynamic configuration

The processes of PHP-FPM can be managed statically or dynamically.

In static mode, the number of child processes is set by the value of `pm.max_children`;

```bash
pm = static
pm.max_children = 10
```

This configuration will launch 10 processes.

In dynamic mode, PHP-FPM will launch at most the number of processes specified by the value of `pm.max_children`, starting by launching some processes corresponding to `pm.start_servers`, and keeping at least the value of `pm.min_spare_servers` of inactive processes and at `most pm.max_spare_servers` inactive processes.

Example:

```bash
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

PHP-FPM will create a new process to replace one that has processed several requests equivalent to `pm.max_requests`.

By default, `pm.max_requests` is set to 0, meaning processes are never recycled. Using the `pm.max_requests` option can be interesting for applications with memory leaks.

There is a third mode of operation, the `ondemand` mode. This mode only starts a process when it receives a request. It is not an optimal mode for sites with strong influences and is to be reserved for specific needs (sites with very weak requests, management backend, etc.).

!!! Note

    The configuration of the operating mode of PHP-FPM is essential to ensure the optimal functioning of your web server.

#### Process status

PHP-FPM offers, like Apache and its `mod_status` module, a page indicating the status of the process.

To activate the page, set its access path via the `pm.status_path` directive:

```bash
pm.status_path = /status
```

```bash
$ curl http://localhost/status_php
pool:                 www
process manager:      dynamic
start time:           03/Dec/2021:14:00:00 +0100
start since:          600
accepted conn:        548
listen queue:         0
max listen queue:     15
listen queue len:     128
idle processes:       3
active processes:     3
total processes:      5
max active processes: 5
max children reached: 0
slow requests:        0
```

#### Logging long requests

The slowlog directive specifies the file that receives logging of requests that are too long (i.e., whose time exceeds the value of the `request_slowlog_timeout` directive).

The default location of the generated file is `/var/log/php-fpm/www-slow.log`.

```bash
request_slowlog_timeout = 5
slowlog = /var/log/php-fpm/www-slow.log
```

A value of 0 for `request_slowlog_timeout` disables logging.

### NGinx integration

The default setting of nginx already includes the necessary configuration to make PHP work with PHP-FPM.

The configuration file `fastcgi.conf` (or `fastcgi_params`) is located under `/etc/nginx/`:

```bash
fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
fastcgi_param  QUERY_STRING       $query_string;
fastcgi_param  REQUEST_METHOD     $request_method;
fastcgi_param  CONTENT_TYPE       $content_type;
fastcgi_param  CONTENT_LENGTH     $content_length;

fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;
fastcgi_param  REQUEST_URI        $request_uri;
fastcgi_param  DOCUMENT_URI       $document_uri;
fastcgi_param  DOCUMENT_ROOT      $document_root;
fastcgi_param  SERVER_PROTOCOL    $server_protocol;
fastcgi_param  REQUEST_SCHEME     $scheme;
fastcgi_param  HTTPS              $https if_not_empty;

fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
fastcgi_param  SERVER_SOFTWARE    nginx/$nginx_version;

fastcgi_param  REMOTE_ADDR        $remote_addr;
fastcgi_param  REMOTE_PORT        $remote_port;
fastcgi_param  SERVER_ADDR        $server_addr;
fastcgi_param  SERVER_PORT        $server_port;
fastcgi_param  SERVER_NAME        $server_name;

# PHP only, required if PHP was built with --enable-force-cgi-redirect
fastcgi_param  REDIRECT_STATUS    200;
```

For nginx to process `.php` files, the following directives must be added to the site configuration file:

If PHP-FPM is listening on port 9000:

```bash
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass 127.0.0.1:9000;
}
```

If php-fpm is listening on a unix socket:

```bash
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass unix:/run/php-fpm/www.sock;
}
```

### Apache integration

The configuration of Apache to use a PHP pool is quite simple. You have to use the proxy modules with a `ProxyPassMatch` directive, for example:

```bash
<VirtualHost *:80>
  ServerName web.rockylinux.org
  DocumentRoot "/var/www/html/current/public"

  <Directory "/var/www/html/current/public">
    AllowOverride All
    Options -Indexes +FollowSymLinks
    Require all granted
  </Directory>
  ProxyPassMatch ^/(.*\.php(/.*)?)$ "fcgi://127.0.0.1:9000/var/www/html/current/public"

</VirtualHost>

```

### Solid configuration of PHP pools

It is essential to optimize the number of requests that will be able to be served and to analyze the memory used by the PHP scripts, to optimize the maximum amount of launched threads.

First of all, we need to know the average amount of memory used by a PHP process with the command:

```bash
while true; do ps --no-headers -o "rss,cmd" -C php-fpm | grep "pool www" | awk '{ sum+=$1 } END { printf ("%d%s\n", sum/NR/1024,"Mb") }' >> avg_php_proc; sleep 60; done
```

After a while, this should give us a pretty accurate idea of the average memory footprint of a PHP process on this server.

The result of the rest of this document is a memory footprint of 120MB per process at full load.

On a server with 8Gb of RAM, keeping 1Gb for the system and 1Gb for the OPCache (see the rest of this document), is 6Gb left to process PHP requests from clients.

We can easily conclude that this server can accept at most **50 threads** `((6*1024) / 120)`.

A good configuration of `php-fpm` specific to this use case would be:

```bash
pm = dynamic
pm.max_children = 50
pm.start_servers = 12
pm.min_spare_servers = 12
pm.max_spare_servers = 36
pm.max_requests = 500
```

with:

* `pm.start_servers` = 25% of `max_children`
* `pm.min_spare_servers` = 25% of `max_children`
* `pm.max_spare_servers` = 75% of `max_children`

### Opcache configuration

The `opcache` (Optimizer Plus Cache) is the first level of cache on which we can influence.

It keeps the compiled PHP scripts in memory, which strongly impacts the execution of the web pages (removes the reading of the script on disk + the compilation time).

To configure it, we must work on:

* The size of the memory dedicated to the opcache according to the hit ratio, configuring it correctly
* The number of PHP scripts to cache (number of keys + maximum number of scripts)
* The number of strings to cache

To install it:

```bash
sudo dnf install php-opcache
```

To configure it, edit the `/etc/php.d/10-opcache.ini` configuration file:

```bash
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
```

where:

* `opcache.memory_consumption` corresponds to the amount of memory needed for the opcache (to be increased until a correct hit ratio is obtained).
* `opcache.interned_strings_buffer` the amount of strings to cache.
* `opcache.max_accelerated_files` is near to the result of the `find ./ -iname "*.php"|wc -l` command.

You can refer to an `info.php` page (including the `phpinfo();`) to configure the opcache (see for example the values of `Cached scripts` and `Cached strings`).

!!! Note

    At each new deployment of new code, it will be necessary to empty the opcache (for example by restarting the php-fpm process).

!!! Note

    Don't underestimate the speed gain that can be achieved by setting up and configuring the opcache correctly.
