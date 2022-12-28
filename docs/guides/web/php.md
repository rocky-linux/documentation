---
title: PHP and PHP-FPM
author: Antoine Le Morvan
contributors: Steven Spencer
tested with: 8.5
tags:
  - web
  - php
  - php-fpm
---

# PHP and PHP-FPM

**PHP** (**P**HP **H**ypertext **P**reprocessor) is a source scripting language, specially designed for web application development. In 2021, PHP represented a little less than 80% of the web pages generated in the world. PHP is open-source and is the core of the most famous CMS (WordPress, Drupal, Joomla!, Magento, ...).

**PHP-FPM** (**F**astCGI **P**rocess **M**anager) is integrated to PHP since its version 5.3.3. The FastCGI version of php brings additional functionalities.

## Generalities

**CGI** (**C**ommon **G**ateway **I**nterface) and **FastCGI** allow communication between the web server (Apache, Nginx, ...) and a development language (Php, Python, Java):

* In the case of **CGI**, each request leads to the creation of a **new process**, which is less efficient in terms of performance.
* **FastCGI** relies on a **certain number of processes** for the treatment of its client requests.

PHP-FPM, **in addition to better performances**, brings:

* The possibility of better **partitioning the applications**: launching processes with different uid/gid, with personalized php.ini files,
* The management of the statistics,
* Log management,
* Dynamic management of processes and restart without service interruption ('graceful').

!!! Note

    Since Apache has a php module, the use of php-fpm is more commonly used on an Nginx server.

## Choose a php version

Rocky Linux, like its upstream, offers many versions of the language. Some of them have reached the end of their life but are kept to continue hosting historical applications that are not yet compatible with new versions of PHP. Please refer to the [ supported versions ](https://www.php.net/supported-versions.php) page of the php.net website to choose a supported version.

To obtain a list of available versions, simply enter the following command:

```
$ sudo dnf module list php
Rocky Linux 8 - AppStream
Name         Stream          Profiles                           Summary                       
php          7.2 [d]         common [d], devel, minimal         PHP scripting language        
php          7.3             common [d], devel, minimal         PHP scripting language        
php          7.4             common [d], devel, minimal         PHP scripting language        

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

Rocky provides, from its AppStream repository, different PHP modules.

You will note that the default version of a Rocky 8.5 is 7.2 which has already reached its end of life at the time of writing.

You can activate a newer module by entering the following command:

```
sudo dnf module enable php:7.4
==============================================================================================
 Package               Architecture         Version               Repository             Size
==============================================================================================
Enabling module streams:
 httpd                                      2.4                                              
 php                                        7.4                                              

Transaction Summary
==============================================================================================

Is this ok [y/N]: y
Complete!
```

!!! Note

    You cannot currently install php 8 from the AppStream repositories. For this, you will have to go through the REMI repository. This installation is not covered in this document.

You can now proceed to the installation of the php engine.

## PHP cgi mode

First, let's see how to install and use php in its CGI mode. We will only be able to make it work with the Apache web server and its `mod_php` module. We will see, later in this document, in the FastCGI part (php-fpm) how to integrate PHP in Nginx (but also Apache).

### Installation

The installation of php is quite trivial, since it consists in installing the main package as well as the few php modules that you will need.

The example below installs php with the modules that are usually installed with it.

```
$ sudo dnf install php php-cli php-gd php-curl php-zip php-mbstring
```

You can check that the installed version corresponds to the expected one:

```
$ php -v
PHP 7.4.19 (cli) (built: May  4 2021 11:06:37) ( NTS )
Copyright (c) The PHP Group
Zend Engine v3.4.0, Copyright (c) Zend Technologies
    with Zend OPcache v7.4.19, Copyright (c), by Zend Technologies
```

### Configuration

### Apache integration

To serve php pages in cgi mode, you will have to install the apache server, configure it, activate it and start it.

* Installation:

```
$ sudo dnf install httpd
```

* Activation:

```
$ sudo systemctl enable httpd
$ sudo systemctl start httpd
$ sudo systemctl status httpd
```

* Don't forget to configure the firewall:

```
$ sudo firewall-cmd --add-service=http --permanent
$ sudo firewall-cmd --reload
```

The default vhost should work out of the box. PHP provides a `phpinfo()` function that generates a summary table of its configuration. It's very useful to test the good working of php. However, be careful not to leave such test files lying around on your servers, they represent a huge security risk for your infrastructure.

Create the file `/var/www/html/info.php` (`/var/www/html` being the default vhost directory of the default apache configuration):

```
<?php
phpinfo();
?>
```

Use a web browser to check that the server is working properly by going to the page http://your-server-ip/info.php.

!!! Warning

    Do not leave the info.php file on your server!

## PHP-FPM (FastCGI)

As we highlighted earlier in this document, there are many advantages to switching web hosting to php-fpm mode.

### Installation

The installation is limited to the php-fpm package:

```
$ sudo dnf install php-fpm
```

As php-fpm is a service from a system point of view, it must be activated and started:

```
$ sudo systemctl enable php-fpm
$ sudo systemctl start php-fpm
$ sudo systemctl status php-fpm
```

### Configuration

The main configuration file is stored under `/etc/php-fpm.conf`.

```
include=/etc/php-fpm.d/*.conf
[global]
pid = /run/php-fpm/php-fpm.pid
error_log = /var/log/php-fpm/error.log
daemonize = yes
```

!!! Note

    The php-fpm configuration files are widely commented. Go and have a look!

As you can see, the files in the `/etc/php-fpm/` directory with the `.conf` extension are always included.

By default, a php process pool, named `www`, is declared in `/etc/php-fpm.d/www.conf`.

```
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
| `[pool]`     | Process pool name. The configuration file can be composed of several process pools (the name of the pool in brackets starts a new section). |
| `listen`     | Defines the listening interface or the unix socket used. |

#### Configuring the way to access php-fpm processes

There are 2 ways to connect.

Via an inet interface such as:

`listen = 127.0.0.1:9000`.

Or via a Unix socket:

`listen = /run/php-fpm/www.sock`.

!!! Note

    The use of a socket when the web server and the php server are on the same machine allows the removal of the TCP/IP layer and optimizes the performances.

When working via an interface, you have to configure `listen.owner`, `listen.group`, `listen.mode` to specify the owner, the owner group and the rights of the Unix socket. **Warning:** both servers (web and php) must have access rights on the socket.

When working via a socket, you have to configure `listen.allowed_clients` to restrict access to the php server to certain IP addresses.

Example: `listen.allowed_clients = 127.0.0.1`

#### Static or dynamic configuration

The processes of php-fpm can be managed statically or dynamically.

In static mode, the number of child processes is set by the value of `pm.max_children`;

```
pm = static
pm.max_children = 10
```

This configuration will launch 10 processes.

In dynamic mode, PHP-FPM will launch at most the number of processes specified by the value of `pm.max_children`, starting by launching a number of processes corresponding to `pm.start_servers`, and keeping at least the value of `pm.min_spare_servers` of inactive processes and at `most pm.max_spare_servers` inactive processes.

Example:

```
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

PHP-FPM will create a new process to replace one that has processed a number of requests equivalent to `pm.max_requests`.

By default, `pm.max_requests` is set to 0, which means that processes are never recycled. Using the `pm.max_requests` option can be interesting for applications with memory leaks.

There is a third mode of operation, the `ondemand` mode. This mode only starts a process when it receives a request. It is not an optimal mode for sites with strong influences, and is to be reserved for specific needs (sites with very weak requests, management backend, etc.).

!!! Note

    The configuration of the operating mode of PHP-FPM is essential to ensure an optimal functioning of your web server.


#### Process status

PHP-FPM offers, like Apache and its `mod_status` module, a page indicating the status of the process.

To activate the page, setup its access path via the `pm.status_path` directive:

```
pm.status_path = /status
```

```
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

```
request_slowlog_timeout = 5
slowlog = /var/log/php-fpm/www-slow.log
```

A value of 0 for `request_slowlog_timeout` disables logging.

### NGinx integration

The default setting of nginx already includes the necessary configuration to make php work with PHP-FPM.

The configuration file `fastcgi.conf` (or `fastcgi_params`) is located under `/etc/nginx/`:

```
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

In order for nginx to process `.php` files, the following directives must be added to the site configuration file:

If php-fpm is listening on port 9000:

```
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass 127.0.0.1:9000;
}
```

If php-fpm is listening on a unix socket:

```
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass unix:/run/php-fpm/www.sock;
}
```

### Apache integration

The configuration of apache to use a php pool is quite simple. You just have to use the proxy modules with a `ProxyPassMatch` directive, for example:

```
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

### Solid configuration of php pools

It is essential, to optimize the quantity of requests which will be able to be served, to analyze the memory used by the php scripts and thus to optimize the maximum quantity of launched threads.

First of all, we need to know the average amount of memory used by a PHP process, with the command:

```
while true; do ps --no-headers -o "rss,cmd" -C php-fpm | grep "pool www" | awk '{ sum+=$1 } END { printf ("%d%s\n", sum/NR/1024,"Mb") }' >> avg_php_proc; sleep 60; done
```

After a while, this should give us a pretty accurate idea of the average memory footprint of a php process on this server.

For the rest of this document, let's say that the result is a memory footprint of 120MB per process at full load.

On a server with 8Gb of RAM, keeping 1Gb for the system and 1Gb for the OPCache (see the rest of this document), there is 6Gb left to process PHP requests from clients.

We can easily conclude that this server can accept at most **50 threads** `((6*1024) / 120)`.

A good configuration of `php-fpm` specific to this use case would be:

```
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

It keeps in memory the compiled php scripts which strongly impacts the execution of the web pages (removes the reading on disk of the script + the compilation time).

To configure it, we must work on:

* The size of the memory dedicated to the opcache according to the hit ratio

By configuring correctly





* the number of php scripts to cache (number of keys + maximum number of scripts)
* the number of strings to cache

To install it:

```
$ sudo dnf install php-opcache
```

To configure it, edit the `/etc/php.d/10-opcache.ini` configuration file:

```
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
