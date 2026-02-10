---
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
title: Chapitre 3 Serveurs d'application
tags:
  - web
  - php
  - php-fpm
  - serveur d'applications
  - langage dynamique
---

## PHP et PHP-FPM

Dans ce chapitre, vous allez découvrir PHP et PHP-FPM.

**PHP** (**P**HP **H**ypertext **P**reprocessor) est un langage de programmation libre spécialement conçu pour le développement d'applications Web. En 2024, PHP représentait un peu moins de 80% des pages web générées dans le monde. PHP est open-source et est le cœur des CMS les plus répandus (WordPress, Drupal, Joomla!, Magento, ...).

**PHP-FPM** (**F**astCGI **P**rocess **M**anager) est intégré à PHP depuis sa version 5.3.3. La version FastCGI de PHP apporte des caractéristiques supplémentaires.

****

**Objectifs** : Vous apprendrez à :

:heavy_check_mark: installer un serveur d'application PHP
:heavy_check_mark: configurer un pool PHP-FPM
:heavy_check_mark: optimiser un serveur d'application PHP-FPM

:checkered_flag: **PHP**, **PHP-FPM**, **Serveur d'Applications**

**Connaissances**: :star: :star: :star:  
**Complexité**: :star: :star: :star:

**Temps de lecture** : 31 minutes

****

### Généralités

**CGI** (\*\*Common \*\*Gateway \*\*Interface) et **FastCGI** permettent la communication entre le serveur web (Apache ou Nginx) et un langage de programmation (PHP, Python, Java) :

- Dans le cas de **CGI**, chaque requête crée un **nouveau processus**, ce qui peut être moins efficace en termes de performances.
- **FastCGI** s'appuie sur un **certain nombre de processus** pour traiter les requêtes de ses clients plus efficacement.

PHP-FPM, **en plus de meilleures performances**, apporte :

- La possibilité de mieux **partitionner les applications** : lancer des processus avec des `uid`/`gid` différents, avec des fichiers `php.ini` personnalisés,
- La gestion de statistiques,
- Gestion de journal,
- Gestion dynamique des processus et redémarrage sans interruption de service (`graceful`).

!!! note "Remarque"

    Since Apache has a PHP module, php-fpm is more commonly used on an Nginx server.

### Choose a PHP version

Rocky Linux, like its upstream, offers many versions of the language. Some of them have reached the end of their life but are kept to continue hosting historical applications that are not yet compatible with new versions of PHP. Please refer to the [supported versions](https://www.php.net/supported-versions.php) page of the php.net website to choose a supported version.

To obtain a list of available versions, enter the following command:

 ```bash
 sudo dnf module list php
 Last metadata expiration check: 0:01:43 ago on Tue 21 Oct 2025 02:12:49 PM UTC.
 Rocky Linux 9 - AppStream
 Name                  Stream                 Profiles                                   Summary
 php                   8.1                    common [d], devel, minimal                 PHP scripting language
 php                   8.2                    common [d], devel, minimal                 PHP scripting language
 php                   8.3                    common [d], devel, minimal                 PHP scripting language
 
 Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
 ```

Vous pouvez désormais activer un module plus récent (PHP 8.3) en entrant la commande suivante :

 ```bash
 sudo dnf module enable php:8.3
 ```

You can now proceed to the installation of the PHP engine.

### Installation du mode CGI de PHP

Tout d’abord, installez et utilisez PHP en mode CGI. Il ne peut fonctionner qu'avec le serveur Web Apache et son module `mod_php`. This document's FastCGI part (php-fpm) explains how to integrate PHP in Nginx (but also Apache).

The installation of PHP is relatively trivial. Elle consiste à installer le package principal et les quelques modules dont vous aurez besoin.

The example below installs PHP with the modules usually installed with it.

 ```bash
 sudo dnf install php php-cli php-gd php-curl php-zip php-mbstring
 ```

Vérifiez votre version avec la commande suivante :

 ```bash
 php -v
 PHP 8.3.19 (cli) (built: Mar 12 2025 13:10:27) (NTS gcc x86_64)
 Copyright (c) The PHP Group
 Zend Engine v4.3.19, Copyright (c) Zend Technologies
    with Zend OPcache v8.3.19, Copyright (c), by Zend Technologies
 ```

### Intégration d'Apache

To serve PHP pages in CGI mode, you must install the Apache server, configure it, activate it, and start it.

- Installation :

 ```bash
 sudo dnf install httpd
 ```

    ```
    activation:
    ```

 ```bash
 sudo systemctl enable --now httpd
 sudo systemctl status httpd
 ```

- Do not forget to configure the firewall:

 ```bash
 sudo firewall-cmd --add-service=http --permanent
 sudo firewall-cmd --reload
 ```

The default vhost should work out of the box. PHP provides a `phpinfo()` function that generates a summary table of its configuration. It is useful to test whether PHP is working well. However, be careful not to leave such test files on your servers. They represent a huge security risk for your infrastructure.

Create the file `/var/www/html/info.php` (`/var/www/html` being the default vhost directory of the default Apache configuration):

```bash
<?php
phpinfo();
?>
```

Use a web browser to check that the server works properly by going to the page [http://your-server-ip/info.php](http://your-server-ip/info.php).

!!! warning "Avertissement"

    Do not leave the `info.php` file on your server!

### Installation of the PHP cgi mode (PHP-FPM)

Noted earlier, many advantages exist for switching web hosting to PHP-FPM mode.

The installation entails only the php-fpm package:

```bash
sudo dnf install php-fpm
```

As php-fpm is a service from a system point of view, you must activate and start it:

```bash
sudo systemctl enable --now php-fpm
sudo systemctl status php-fpm
```

#### Configuration of the PHP cgi mode

The main configuration file is `/etc/php-fpm.conf`.

```bash
include=/etc/php-fpm.d/*.conf
[global]
pid = /run/php-fpm/php-fpm.pid
error_log = /var/log/php-fpm/error.log
daemonize = yes
```

!!! note "Remarque"

    The php-fpm configuration files are widely commented on. Go and have a look!

As you can see, the files in the `/etc/php-fpm.d/` directory with the `.conf` extension are always included.

By default, a PHP process pool declaration named `www`, is in `/etc/php-fpm.d/www.conf`.

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

| Instructions | Description                                                                                                                                                                         |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `[pool]`     | Process pool name. The configuration file can comprise several process pools (the pool's name in brackets starts a new section). |
| `listen`     | Defines the listening interface or the Unix socket used.                                                                                                            |

#### Configuring the way to access php-fpm processes

Two ways exist for connecting.

With an `inet-interface` such as:

`listen = 127.0.0.1:9000`.

Or with a UNIX socket:

`listen = /run/php-fpm/www.sock`.

!!! note "Remarque"

    Using a socket when the web server and PHP server are on the same machine removes the TCP/IP layer and optimizes the performance.

When working with an interface, you have to configure `listen.owner`, `listen.group`, `listen.mode` to specify the owner, the owner group, and the rights of the UNIX socket. **Warning:** Both servers (web and PHP) must have access rights on the socket.

When working with a socket, you must configure `listen.allowed_clients` to restrict access to the PHP server to certain IP addresses.

Example: `listen.allowed_clients = 127.0.0.1`

#### Static or dynamic configuration

You can manage PHP-FPM processes statically or dynamically.

In static mode, `pm.max_children` sets a limit to the number of child processes:

```bash
pm = static
pm.max_children = 10
```

This configuration starts with 10 processes.

In dynamic mode, PHP-FPM starts at _most_ the number of processes specified by the`pm.max_children` value. It first starts some processes corresponding to `pm.start_servers`, keeping at least the value of `pm.min_spare_servers` of inactive processes and, at most, `pm.max_spare_servers` of inactive processes.

Exemple :

```bash
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

PHP-FPM will create a new process to replace one that has processed several requests equivalent to `pm.max_requests`.

By default, the value of `pm.max_requests` is 0, meaning processes are never recycled. The `pm.max_requests` option can be attractive for applications with memory leaks.

A third mode of operation is the `ondemand` mode. This mode only starts a process when it receives a request. It is not an optimal mode for sites with strong influences and is reserved for specific needs (sites with feeble requests, management backend, etc.).

!!! note "Remarque"

    The configuration of the operating mode of PHP-FPM is essential to ensure the optimal functioning of your web server.

#### Process status

Semblable à Apache et son module `mod_status`, PHP-FPM propose une page d'état de processus.

To activate the page, set its access path with the `pm.status_path` directive:

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

The `slowlog` directive specifies the file that receives logging requests that are too long (for instance, whose time exceeds the value of the `request_slowlog_timeout` directive).

The default location of the generated file is `/var/log/php-fpm/www-slow.log`.

```bash
request_slowlog_timeout = 5
slowlog = /var/log/php-fpm/www-slow.log
```

A value of 0 for `request_slowlog_timeout` disables logging.

### NGinx integration

The default setting of nginx already includes the necessary configuration to make PHP work with PHP-FPM.

The configuration file `fastcgi.conf` (or `fastcgi_params`) is under `/etc/nginx/`:

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

For nginx to process `.php` files, add the following directives to the site configuration file:

If PHP-FPM is listening on port 9000:

```bash
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass 127.0.0.1:9000;
}
```

If php-fpm is listening on a UNIX socket:

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

Optimizing the number of requests served and analyzing the memory used by the PHP scripts is necessary to maximize the number of launched threads.

First of all, you need to know the average amount of memory used by a PHP process with the command:

```bash
while true; do ps --no-headers -o "rss,cmd" -C php-fpm | grep "pool www" | awk '{ sum+=$1 } END { printf ("%d%s\n", sum/NR/1024,"Mb") }' >> avg_php_proc; sleep 60; done
```

This will give you a pretty accurate idea of the average memory footprint of a PHP process on this server.

Le résultat du reste de ce document est une empreinte mémoire de 120 Mo par processus à pleine charge.

On a server with 8Gb of RAM, keeping 1Gb for the system and 1Gb for the OPCache (see the rest of this document), is 6Gb left to process PHP requests from clients.

You can conclude that this server can accept at most **50 threads** `((6*1024) / 120)`.

An exemplary configuration of `php-fpm` specific to this use case is:

```bash
pm = dynamic
pm.max_children = 50
pm.start_servers = 12
pm.min_spare_servers = 12
pm.max_spare_servers = 36
pm.max_requests = 500
```

avec :

- `pm.start_servers` = 25% of `max_children`
- `pm.min_spare_servers` = 25% of `max_children`
- `pm.max_spare_servers` = 75% of `max_children`

### Opcache configuration

The `opcache` (Optimizer Plus Cache) is the first level of cache that you can influence.

It keeps the compiled PHP scripts in memory, which strongly impacts the execution of the web pages (removes the reading of the script on disk + the compilation time).

To configure it, you must work on:

- The size of the memory dedicated to the opcache according to the hit ratio, configuring it correctly
- The number of PHP scripts to cache (number of keys + maximum number of scripts)
- The number of strings to cache

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

Where:

- `opcache.memory_consumption` corresponds to the amount of memory needed for the opcache (increase this until obtaining a correct hit ratio).
- `opcache.interned_strings_buffer` is the amount of strings to cache.
- `opcache.max_accelerated_files` is near to the result of the `find ./ -iname "*.php"|wc -l` command.

To configure the opcache, refer to an `info.php` page (including the `phpinfo();`) (see, for example, the values of `Cached scripts` and `Cached strings`).

!!! note "Remarque"

    Lors de chaque nouveau déploiement de code récent, il sera nécessaire de vider l'`opcache` (par exemple en redémarrant le processus php-fpm).

!!! note "Remarque"

    Ne sous-estimez pas les gains de vitesse qui peuvent être obtenus en installant et en configurant correctement `opcache`.

<!---

### Workshop

#### Task 1 : XXX

#### Task 2 : XXX

#### Task 3 : XXX

#### Task 4 : XXX

### Check your Knowledge

:heavy_check_mark: Simple question? (3 answers)

:heavy_check_mark: Question with multiple answers?

* [ ] Answer 1
* [ ] Answer 2
* [ ] Answer 3
* [ ] Answer 4

## Python

In this chapter, you will learn about XXXXXXX.

****

**Objectives**: In this chapter, you will learn how to:

:heavy_check_mark: XXX
:heavy_check_mark: XXX

:checkered_flag: **XXX**, **XXX**

**Knowledge**: :star:
**Complexity**: :star:

**Reading time**: XX minutes

****

### Generalities

### Configuration

### Security

### Workshop

#### Task 1 : XXX

#### Task 2 : XXX

#### Task 3 : XXX

#### Task 4 : XXX

### Check your Knowledge

:heavy_check_mark: Simple question? (3 answers)

:heavy_check_mark: Question with multiple answers?

* [ ] Answer 1
* [ ] Answer 2
* [ ] Answer 3
* [ ] Answer 4

-->
