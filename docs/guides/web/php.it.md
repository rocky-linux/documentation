---
title: PHP e PHP-FPM
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova, Joseph Brinkman
tested_with: 9.3, 8.9
tags:
  - web
  - php
  - php-fpm
---

# PHP e PHP-FPM

**PHP** (**P**HP **H**ypertext **P**reprocessor) is a source scripting language specially designed for web application development. Nel 2024, PHP rappresentava poco meno dell'80% delle pagine web generate nel mondo. PHP è open-source ed è il nucleo dei più famosi CMS (WordPress, Drupal, Joomla!, Magento, ed altri).

**PHP-FPM** (**F**astCGI **P**rocess **M**anager) è integrato nel PHP dalla sua versione 5.3.3. La versione FastCGI di PHP offre ulteriori funzionalità.

## Generalità

**CGI** (**C**ommon **G**ateway **I**nterface) and **FastCGI** allow communication between the web server (Apache, Nginx, and others) and a development language (PHP, Python, Java):

- In the case of **CGI**, each request creates a **new process**, which is less efficient in performance.
- **FastCGI** relies on a **certain number of processes** to treat its client requests.

PHP-FPM, **in addition to better performances**, brings:

- The possibility of better **partitioning the applications**: launching processes with different uid/gid, with personalized `php.ini` files,
- La gestione delle statistiche,
- Gestione del registro,
- Gestione dinamica dei processi e riavvio senza interruzione del servizio ('graceful').

!!! Note

    ```
    Poiché Apache ha un modulo PHP, `php-fpm`è più comunemente usato su un server Nginx.
    ```

## Scegliere una versione PHP

Rocky Linux, as with its upstream, offers many versions of the language. Some of them have reached the end of their life but are there to continue hosting historical applications that are not yet compatible with new versions of PHP. Please refer to the [supported versions](https://www.php.net/supported-versions.php) page of the php.net website to choose a supported version.

To obtain a list of available versions, enter the following command:

```bash
sudo dnf module list php

Last metadata expiration check: 4:28:28 ago on Wed 22 Oct 2025 10:39:41 AM UTC.
Rocky Linux 9 - AppStream
Name                 Stream                  Profiles                                   Summary                               
php                  8.1                     common [d], devel, minimal                 PHP scripting language                
php                  8.2                     common [d], devel, minimal                 PHP scripting language                
php                  8.3                     common [d], devel, minimal                 PHP scripting language                

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

Attivare la versione più recente di PHP con:

 ```bash
 sudo dnf module enable php:8.3
 ```

Ora si può procedere all'installazione del motore PHP.

## Modalità PHP cgi

First, install PHP in CGI mode. You can only make it work with the Apache web server and its `mod_php` module. Vedremo più avanti in questo documento, nella parte dedicata a FastCGI (`php-fpm`), come integrare PHP in Nginx e Apache.

### Install PHP

Installazione di PHP e alcuni moduli comunemente utilizzati:

```bash
sudo dnf install php php-cli php-gd php-curl php-zip php-mbstring
```

È possibile verificare che la versione installata corrisponda a quella prevista:

```bash
php -v
PHP 8.3.19 (cli) (built: Mar 12 2025 13:10:27) (NTS gcc x86_64)
Copyright (c) The PHP Group
Zend Engine v4.3.19, Copyright (c) Zend Technologies
   with Zend OPcache v8.3.19, Copyright (c), by Zend Technologies
```

### Configurazione

#### Integrazione con Apache

Per servire pagine PHP in modalità CGI, è necessario installare il server Apache, configurarlo, attivarlo e avviarlo.

- Installazione:

 ```bash
 sudo dnf install httpd
 ```

    ```
    * Attivazione:
    ```

 ```bash
 sudo systemctl enable --now httpd
 sudo systemctl status httpd
 ```

- Non dimenticare di configurare il firewall:

 ```bash
 sudo firewall-cmd --add-service=http --permanent
 sudo firewall-cmd --reload
 ```

Il vhost predefinito dovrebbe funzionare immediatamente. PHP provides a `phpinfo()` function that generates a summary table of its configuration. It is very useful to test the good working of PHP. Tuttavia, fate attenzione a non lasciare tali file di prova sui vostri server. Rappresentano un enorme rischio per la sicurezza della vostra infrastruttura.

Create the file `/var/www/html/info.php` (`/var/www/html` being the default vhost directory of the default Apache configuration):

```bash
<?php
phpinfo();
?>
```

Use a web browser to check that the server works properly by going to the page [http://your-server-ip/info.php](http://your-server-ip/info.php).

!!! Warning Attenzione

    ```
    Non lasciare il file `info.php` sul tuo server!
    ```

## PHP-FPM (FastCGI)

Come abbiamo evidenziato in precedenza in questo documento, ci sono molti vantaggi nel passare l'hosting web alla modalità PHP-FPM.

### Install PHP-FPM

Installare il pacchetto `php-fpm` con:

```bash
sudo dnf install php-fpm
```

As `php-fpm` is a service from a system point of view, you must activate and start it:

```bash
sudo systemctl enable --now php-fpm
sudo systemctl status php-fpm
```

### Configurazione

`php-fpm` memorizza il file di configurazione principale in `/etc/php-fpm.conf`:

```bash
include=/etc/php-fpm.d/*.conf
[global]
pid = /run/php-fpm/php-fpm.pid
error_log = /var/log/php-fpm/error.log
daemonize = yes
```

!!! Note

    ```
    The `php-fpm` configuration files are widely commented on. Go and have a look!
    ```

As you can see, the files in the `/etc/php-fpm.d/` directory with the `.conf` extension are always included.

By default, `php-fpm` declares a PHP process pool named `www` in `/etc/php-fpm.d/www.conf`:

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

| Istruzioni | Descrizione                                                                                                                                                                                                 |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `[pool]`   | Nome del pool di processi. Il file di configurazione può comprendere diversi pool di processi (il nome del pool tra parentesi inizia una nuova sezione). |
| `listen`   | Definisce l'interfaccia di ascolto o il socket unix utilizzato.                                                                                                                             |

#### Configuring the way to access `php-fpm` processes

Ci sono due modi per connettersi.

Via an inet interface such as:

`listen = 127.0.0.1:9000`.

Oppure con un socket Unix:

`listen = /run/php-fpm/www.sock`.

!!! Note

    ```
    Utilizzando un socket, quando il server web e il server PHP si trovano sulla stessa macchina, si elimina il livello TCP/IP e si ottimizzano le prestazioni.
    ```

When working with an interface, you have to configure `listen.owner`, `listen.group`, `listen.mode` to specify the owner, the owner group and the rights of the Unix socket. **Warning:** Both servers (web and PHP) must have access rights on the socket.

When working with a socket, you must configure `listen.allowed_clients` to restrict access to the PHP server to certain IP addresses.

Example: `listen.allowed_clients = 127.0.0.1`

#### Configurazione statica o dinamica

È possibile gestire i processi di PHP-FPM in modo statico o dinamico.

In modalità statica, `pm.max_children` imposta il numero di processi figli:

```bash
pm = static
pm.max_children = 10
```

Questa configurazione avvierà 10 processi.

In modalità dinamica, PHP-FPM avvierà al massimo il numero di processi specificato dal valore di `pm.max_children`, iniziando con l'avvio di alcuni processi corrispondenti a `pm.start_servers` e mantenendo almeno il valore di `pm.min_spare_servers` di processi inattivi e al massimo `pm.max_spare_servers` di processi inattivi.

Esempio:

```bash
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

PHP-FPM will create a new process to replace one that has processed several requests equivalent to `pm.max_requests`.

Per impostazione predefinita, il valore impostato per `pm.max_requests` è 0, il che significa che i processi non vengono mai riciclati. Using the `pm.max_requests` option can be interesting for applications with memory leaks.

There is a third mode of operation, the `ondemand` mode. Questa modalità avvia un processo solo quando riceve una richiesta. It is not an optimal mode for sites with strong influences and you should reserve it for specific needs (sites with very weak requests, management backend, and so on).

!!! Note

    ```
    La configurazione della modalità operativa di PHP-FPM è essenziale per garantire il funzionamento ottimale del server web.
    ```

#### Stato del processo

PHP-FPM offers, similar to Apache and its `mod_status` module, a page indicating the status of the process.

Per attivare la pagina, impostare il percorso di accesso con la direttiva `pm.status_path`:

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

#### Registrazione di richieste lunghe

La direttiva `slowlog` specifica il file che riceve la registrazione delle richieste troppo lunghe (ad esempio, un file il cui tempo supera il valore della direttiva `request_slowlog_timeout`).

La posizione predefinita del file generato è `/var/log/php-fpm/www-slow.log`:

```bash
request_slowlog_timeout = 5
slowlog = /var/log/php-fpm/www-slow.log
```

A value of 0 for `request_slowlog_timeout` disables logging.

### Integrazione con NGinx

The default setting of `nginx` already includes the necessary configuration to make PHP work with PHP-FPM.

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

Affinché `nginx` possa elaborare i file `.php`, è necessario aggiungere le seguenti direttive al file di configurazione del sito:

Se PHP-FPM è in ascolto sulla porta 9000:

```bash
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass 127.0.0.1:9000;
}
```

Se `php-fpm` è in ascolto su un socket Unix:

```bash
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass unix:/run/php-fpm/www.sock;
}
```

### Integrazione con Apache

La configurazione di apache per utilizzare un pool PHP è abbastanza semplice. You have to use the proxy modules with a `ProxyPassMatch` directive, for example:

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

### Configurazione consistente dei pool PHP

È essenziale ottimizzare il numero di richieste servite e analizzare la memoria utilizzata dagli script PHP, per ottimizzare il numero massimo di thread avviati.

Prima di tutto, è necessario conoscere la quantità media di memoria utilizzata da un processo PHP con il comando:

```bash
while true; do ps --no-headers -o "rss,cmd" -C php-fpm | grep "pool www" | awk '{ sum+=$1 } END { printf ("%d%s\n", sum/NR/1024,"Mb") }' >> avg_php_proc; sleep 60; done
```

Dopo un po' di tempo, questo dovrebbe darci un'idea abbastanza precisa dell'uso medio della memoria di un processo PHP su questo server.

Il risultato del resto di questo documento è un uso di memoria di 120 megabyte per ogni processo a pieno carico.

Su un server con 8 gigabyte di RAM, mantenendo 1 gigabyte per il sistema e 1 gigabyte per l'OPCache (vedere il resto di questo documento), rimangono 6 gigabyte per elaborare le richieste PHP dai client.

You can conclude that this server can accept at most **50 threads** `((6*1024) / 120)`.

A good configuration of `php-fpm` specific to this use case would be:

```bash
pm = dynamic
pm.max_children = 50
pm.start_servers = 12
pm.min_spare_servers = 12
pm.max_spare_servers = 36
pm.max_requests = 500
```

con:

- `pm.start_servers` = 25% of `max_children`
- `pm.min_spare_servers` = 25% of `max_children`
- `pm.max_spare_servers` = 75% of `max_children`

### Configurazione di OPCache

The `opcache` (Optimizer Plus Cache) is the first level of cache on which we can influence.

Mantiene gli script PHP compilati in memoria, il che ha un forte impatto sull'esecuzione delle pagine web (elimina la lettura su disco degli script + il tempo di compilazione).

Per configurarlo, dobbiamo lavorare su:

- The size of the memory dedicated to the `opcache` according to the hit ratio, configuring it correctly
- Il numero di script PHP da mettere in cache (numero di chiavi + numero massimo di script)
- il numero di stringhe da mettere in cache

Per installarla:

```bash
sudo dnf install php-opcache
```

To configure it, edit the `/etc/php.d/10-opcache.ini` configuration file:

```bash
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
```

dove:

- `opcache.memory_consumption` corrisponde alla quantità di memoria necessaria per `opcache` (aumentarla fino a ottenere un rapporto di successo corretto).
- `opcache.interned_strings_buffer` the amount of strings to cache.
- `opcache.max_accelerated_files` is near to the result of the `find ./ -iname "*.php"|wc -l` command.

You can refer to an `info.php` page (including the `phpinfo();`) to configure the `opcache` (see for example the values of `Cached scripts` and `Cached strings`).

!!! Note

    ```
    At each new deployment of new code, it will be necessary to empty the opcache (for example by restarting the `php-fpm` process).
    ```

!!! Note

    ```
    Do not underestimate the speed gain that can be achieved by setting up and configuring the `opcache` correctly.
    ```
