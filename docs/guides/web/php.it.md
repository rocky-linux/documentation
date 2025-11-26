---
title: PHP e PHP-FPM
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova, Joseph Brinkman
tested_with: 10.0
tags:
  - web
  - php
  - php-fpm
---

# PHP e PHP-FPM

**PHP** (**P**HP **H**ypertext **P**reprocessor) è un linguaggio di scripting sorgente appositamente progettato per lo sviluppo di applicazioni web. Nel 2024, PHP rappresentava poco meno dell'80% delle pagine web generate nel mondo. PHP è open-source ed è il cuore dei più famosi CMS (WordPress, Drupal, Joomla!, Magento, ...).

**PHP-FPM** (**F**astCGI **P**rocess **M**anager) è integrato in PHP fin dalla versione 5.3.3. La versione FastCGI di PHP offre ulteriori funzionalità.

## Generalità

**CGI** (**C**ommon **G**ateway **I**nterface) e **FastCGI** consentono la comunicazione tra il server web (Apache, Nginx, ...) e un linguaggio di sviluppo (PHP, Python, Java):

* Nel caso di **CGI**, ogni richiesta crea un **nuovo processo**, il che è meno efficiente in termini di prestazioni.
* **FastCGI** si affida a un **certo numero di processi** per trattare le richieste dei clienti.

PHP-FPM, **oltre a prestazioni migliori**, porta con sé:

* La possibilità di una migliore **separazione delle applicazioni**: lancio di processi con uid/gid diversi, con file `php.ini` personalizzati,
* La gestione delle statistiche,
* Gestione del registro,
* Gestione dinamica dei processi e riavvio senza interruzione del servizio ('graceful').

!!! Note

    Poiché Apache ha un modulo PHP, php-fpm è più comunemente usato su un server Nginx.

## Scegliere una versione PHP

Rocky Linux 10, come il suo upstream, non ha più moduli. La versione di PHP è quella disponibile nel repository Appstream. Per verificare la versione disponibile di PHP, utilizzare:

```bash
dnf whatprovides php

Last metadata expiration check: 0:00:03 ago on Wed 22 Oct 2025 03:58:30 PM UTC.

php-8.3.19-1.el10_0.x86_64 : PHP scripting language for creating dynamic web sites
Repo        : @System
Matched from:
Provide    : php = 8.3.19-1.el10_0

php-8.3.19-1.el10_0.x86_64 : PHP scripting language for creating dynamic web sites
Repo        : appstream
Matched from:
Provide    : php = 8.3.19-1.el10_0
```

Ora si può procedere all'installazione del motore PHP.

## Modalità PHP cgi

Per prima cosa, instalare PHP. È possibile farlo funzionare solo con il server web Apache e il suo modulo `mod_php`. Più avanti in questo documento, nella parte dedicata a FastCGI (`php-fpm`), si vedrà come integrare PHP in Nginx e Apache.

### Installazione

L'installazione di PHP è relativamente semplice, poiché consiste nell'installare il pacchetto principale e i pochi moduli necessari.

Questo esempio installa PHP con i moduli comunemente installati con esso:

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

* Installazione:

 ```bash
 sudo dnf install httpd
 ```

    * Attivazione:

 ```bash
 sudo systemctl enable --now httpd
 sudo systemctl status httpd
 ```

* Non dimenticare di configurare il firewall:

 ```bash
 sudo firewall-cmd --add-service=http --permanent
 sudo firewall-cmd --reload
 ```

Il vhost predefinito dovrebbe funzionare immediatamente. PHP fornisce una funzione `phpinfo()` che genera una tabella riassuntiva della sua configurazione. It is very useful to test the good working of PHP. Tuttavia, fate attenzione a non lasciare tali file di prova sui vostri server. Rappresentano un enorme rischio per la sicurezza della vostra infrastruttura.

Create il file `/var/www/html/info.php` (`/var/www/html` è la cartella vhost della configurazione predefinita di Apache):

```bash
<?php
phpinfo();
?>
```

Utilizzate un browser web per verificare il corretto funzionamento del server accedendo alla pagina [http://your-server-ip/info.php](http://your-server-ip/info.php).

!!! Warning Attenzione

    Non lasciare il file `info.php` sul tuo server!

## PHP-FPM (FastCGI)

Come abbiamo evidenziato in precedenza in questo documento, ci sono molti vantaggi nel passare l'hosting web alla modalità PHP-FPM.

### Installare `php-fpm`

Per installare il pacchetto `php-fpm` utilizzare:

```bash
sudo dnf install php-fpm
```

Poiché `php-fpm` è un servizio dal punto di vista del sistema, è necessario attivarlo e avviarlo:

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

    I file di configurazione `php-fpm` sono ampiamente commentati. Andate a dare un'occhiata!

Come si può vedere, i file della cartella `/etc/php-fpm.d/` con estensione `.conf` sono sempre inclusi.

Per impostazione predefinita, `php-fpm` dichiara un pool di processi PHP denominato `www` in `/etc/php-fpm.d/www.conf`:

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

| Istruzioni | Descrizione                                                                                                                                              |
| ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `[pool]`   | Nome del pool di processi. Il file di configurazione può comprendere diversi pool di processi (il nome del pool tra parentesi inizia una nuova sezione). |
| `listen`   | Definisce l'interfaccia di ascolto o il socket unix utilizzato.                                                                                          |

#### Configurare il modo di accedere ai processi di `php-fpm`

Ci sono due modi per connettersi.

Con un'interfaccia inet come:

`listen = 127.0.0.1:9000`.

Oppure con un socket Unix:

`listen = /run/php-fpm/www.sock`.

!!! Note

    Utilizzando un socket, quando il server web e il server PHP si trovano sulla stessa macchina, si elimina il livello TCP/IP e si ottimizzano le prestazioni.

Quando si lavora con un'interfaccia, è necessario configurare `listen.owner`, `listen.group`, `listen.mode` per specificare il proprietario, il gruppo proprietario e i diritti del socket Unix. **Attenzione:** Entrambi i server (web e PHP) devono avere i diritti di accesso al socket.

Quando si lavora con un socket, è necessario configurare `listen.allowed_clients` per limitare l'accesso al server PHP a determinati indirizzi IP.

Esempio: `listen.allowed_clients = 127.0.0.1`

#### Configurazione statica o dinamica

You can manage the processes of PHP-FPM either statically or dynamically.

In modalità statica, `pm.max_children` imposta il numero di processi figlio:

```bash
pm = static
pm.max_children = 10
```

Questa configurazione avvierà 10 processi.

In modalità dinamica, PHP-FPM avvierà al massimo il numero di processi specificato dal valore di `pm.max_children`, iniziando ad avviare alcuni processi corrispondenti a `pm.start_servers` e mantenendo almeno il valore di `pm.min_spare_servers` dei processi inattivi e al massimo ` pm.max_spare_servers` dei processi inattivi.

Esempio:

```bash
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

PHP-FPM creerà un nuovo processo per sostituire quello che ha elaborato più richieste equivalenti a `pm.max_requests`.

Per impostazione predefinita, `php-fpm` imposta `pm.max_requests` su 0, il che significa che i processi non vengono mai riciclati. L'uso dell'opzione `pm.max_requests` può essere interessante per le applicazioni con perdite di memoria.

Esiste una terza modalità di funzionamento, quella `ondemand`. Questa modalità avvia un processo solo quando riceve una richiesta. Non è una modalità ottimale per siti con forti affluenze e si dovrebbe riservarla per esigenze specifiche (siti con flussi richieste molto deboli, backend di gestione e così via).

!!! Note

    La configurazione della modalità operativa di PHP-FPM è essenziale per garantire il funzionamento ottimale del server web.

#### Stato del processo

Come Apache e il suo modulo `mod_status`, PHP-FPM offre una pagina che indica lo stato del processo.

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

La posizione predefinita del file generato è `/var/log/php-fpm/www-slow.log`.

```bash
request_slowlog_timeout = 5
slowlog = /var/log/php-fpm/www-slow.log
```

Un valore di 0 per `request_slowlog_timeout` disabilita la registrazione.

### Integrazione con NGinx

L'impostazione predefinita di `nginx` include già la configurazione necessaria per far funzionare PHP con PHP-FPM.

Il file di configurazione `fastcgi.conf` (o `fastcgi_params`) si trova in `/etc/nginx/`:

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

PHP-FPM offre, come Apache e il suo modulo `mod_status`, una pagina che indica lo stato del processo.

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

La configurazione di apache per utilizzare un pool PHP è abbastanza semplice. È necessario utilizzare i moduli proxy con una direttiva `ProxyPassMatch`, ad esempio:

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

It is essential to optimize the number of served requests, and to analyze the memory used by the PHP scripts, to optimize the maximum amount of launched threads.

Prima di tutto, è necessario conoscere la quantità media di memoria utilizzata da un processo PHP con il comando:

```bash
while true; do ps --no-headers -o "rss,cmd" -C php-fpm | grep "pool www" | awk '{ sum+=$1 } END { printf ("%d%s\n", sum/NR/1024,"Mb") }' >> avg_php_proc; sleep 60; done
```

Dopo un po' di tempo, questo dovrebbe darci un'idea abbastanza precisa dell'uso medio della memoria di un processo PHP su questo server.

Il risultato del resto di questo documento è un uso di memoria di 120 megabyte per ogni processo a pieno carico.

On a server with 8 gigabytes of RAM, keeping 1 gigabyte for the system and 1 gigabyte for the OPCache (see the rest of this document), 6 gigabytes is left to process PHP requests from clients.

Si può concludere che questo server può accettare al massimo **50 thread** `((6*1024) / 120)`.

Una buona configurazione di `php-fpm` specifica per questo caso d'uso sarebbe:

```bash
pm = dynamic
pm.max_children = 50
pm.start_servers = 12
pm.min_spare_servers = 12
pm.max_spare_servers = 36
pm.max_requests = 500
```

con:

* `pm.start_servers` = 25% di `max_children`
* `pm.min_spare_servers` = 25% di `max_children`
* `pm.max_spare_servers` = 75% di `max_children`

### Configurazione di Opcache

L'`opcache` (Optimizer Plus Cache) è il primo livello di cache su cui possiamo intervenire.

Mantiene gli script PHP compilati in memoria, il che ha un forte impatto sull'esecuzione delle pagine web (elimina la lettura su disco degli script + il tempo di compilazione).

Per configurarlo, dobbiamo lavorare su:

* La dimensione della memoria dedicata all'`opcache` in base al rapporto di hit, configurandola correttamente
* Il numero di script PHP da mettere in cache (numero di chiavi + numero massimo di script)
* il numero di stringhe da mettere in cache

Per installarla:

```bash
sudo dnf install php-opcache
```

Per configurarlo, modificare il file di configurazione `/etc/php.d/10-opcache.ini`:

```bash
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
```

dove:

* `opcache.memory_consumption` corrisponde alla quantità di memoria necessaria per `opcache` (aumentarla fino a ottenere un rapporto di successo corretto).
* `opcache.interned_strings_buffer` la quantità di stringhe da mettere in cache.
* `opcache.max_accelerated_files` è simile al risultato del comando `find ./ -iname "*.php"|wc -l`.

È possibile fare riferimento alla pagina `info.php` (incluso il comando `phpinfo();`) per configurare `opcache` (vedere ad esempio i valori di `Cached scripts` e `Cached strings`).

!!! Note

    Ad ogni nuova implementazione di codice, sarà necessario svuotare l'opcache (ad esempio riavviando il processo php-fpm).

!!! Note

    Do not underestimate the speed gain that can be achieved by setting up and configuring the `opcache` correctly.
