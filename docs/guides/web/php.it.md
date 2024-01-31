---
title: PHP e PHP-FPM
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.9
tags:
  - web
  - php
  - php-fpm
---

# PHP e PHP-FPM

!!! warning "Scritto per Rocky Linux 8.x"

    Questa procedura è stata pubblicata inizialmente quando Rocky Linux 8.x era l'unica versione. Questa procedura deve essere testata e riscritta per Rocky Linux 9.x.

**PHP** (**P**HP **H**ypertext **P**reprocessor) è un linguaggio di scripting sorgente, appositamente progettato per lo sviluppo di applicazioni web. Nel 2021, PHP rappresentava poco meno dell'80% delle pagine web generate nel mondo. PHP è open-source ed è il nucleo dei più famosi CMS (WordPress, Drupal, Joomla!, Magento, ...).

**PHP-FPM** (**F**astCGI **P**rocess **M**anager) è integrato nel PHP dalla sua versione 5.3.3. La versione FastCGI di PHP offre ulteriori funzionalità.

## Generalità

**CGI** (**C**ommon **G**ateway **I**nterface) e **FastCGI** permettono la comunicazione tra il server web (Apache, Nginx, ...) e un linguaggio di sviluppo (PHP, Python, Java):

* Nel caso di **CGI**, ogni richiesta porta alla creazione di un **nuovo processo**, che è meno efficiente in termini di prestazioni.
* **FastCGI** si basa su un **certo numero di processi** per il trattamento delle sue richieste client.

PHP-FPM, **oltre a prestazioni migliori**, porta con sé:

* La possibilità di una migliore **separazione delle applicazioni**: lancio di processi con uid/gid diversi, con file `php.ini` personalizzati,
* La gestione delle statistiche,
* Gestione del registro,
* Gestione dinamica dei processi e riavvio senza interruzione del servizio ('graceful').

!!! Note "Nota"

    Poiché Apache ha un modulo PHP, php-fpm è più comunemente usato su un server Nginx.

## Scegliere una versione PHP

Rocky Linux, come il suo upstream, offre molte versioni del linguaggio. Alcuni di essi hanno raggiunto la fine del loro ciclo di vita, ma vengono mantenuti per continuare a ospitare applicazioni storiche che non sono ancora compatibili con le nuove versioni di PHP. Fare riferimento alla pagina [versioni supportate](https://www.php.net/supported-versions.php) del sito web php.net per scegliere una versione supportata.

Per ottenere un elenco delle versioni disponibili, basta inserire il seguente comando:

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

Rocky fornisce, dal proprio repository AppStream, diversi moduli PHP.

Si noterà che la versione predefinita di Rocky 8.9 è la 7.2, che ha già raggiunto la fine del suo ciclo di vita al momento in cui si scrive.

È possibile attivare un modulo più recente immettendo il seguente comando:

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

Ora si può procedere all'installazione del motore PHP.

## Modalità PHP cgi

Per prima cosa, vediamo come installare e utilizzare PHP in modalità CGI. Possiamo farlo funzionare solo con il server web Apache e il suo modulo `mod_php`. Vedremo più tardi in questo documento, nella parte FastCGI (php-fpm) come integrare PHP in Nginx (ma anche in Apache).

### Installazione

L'installazione di PHP è relativamente banale, poiché consiste nell'installare il pacchetto principale e i pochi moduli necessari.

L'esempio seguente installa PHP con i moduli normalmente installati con esso.

```bash
sudo dnf install php php-cli php-gd php-curl php-zip php-mbstring
```

È possibile verificare che la versione installata corrisponda a quella prevista:

```bash
$ php -v
PHP 7.4.19 (cli) (built: May  4 2021 11:06:37) ( NTS )
Copyright (c) The PHP Group
Zend Engine v3.4.0, Copyright (c) Zend Technologies
    with Zend OPcache v7.4.19, Copyright (c), by Zend Technologies
```

### Configurazione

#### Integrazione con Apache

Per servire pagine PHP in modalità CGI, è necessario installare il server apache, configurarlo, attivarlo e avviarlo.

* Installazione:

```bash
sudo dnf install httpd
```

* Attivazione:

```bash
sudo systemctl enable httpd
sudo systemctl start httpd
sudo systemctl status httpd
```

* Non dimenticatevi di configurare il firewall:

```bash
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --reload
```

Il vhost predefinito dovrebbe funzionare subito. PHP fornisce una funzione `phpinfo()` che genera una tabella riassuntiva della sua configurazione. È molto utile per testare il buon funzionamento di PHP. Tuttavia, fate attenzione a non lasciare tali file di prova sui vostri server. Rappresentano un enorme rischio per la sicurezza della vostra infrastruttura.

Creare il file `/var/www/html/info.php` (`/var/www/html` è la cartella vhost della configurazione predefinita di apache):

```bash
<?php
phpinfo();
?>
```

Utilizzare un browser web per verificare il corretto funzionamento del server accedendo alla pagina [http://your-server-ip/info.php](http://your-server-ip/info.php).

!!! Warning "Attenzione"

    Non lasciare il file info.php sul vostro server!

## PHP-FPM (FastCGI)

Come abbiamo evidenziato in precedenza in questo documento, ci sono molti vantaggi nel passare l'hosting web alla modalità PHP-FPM.

### Installazione

L'installazione è limitata al pacchetto php-fpm:

```bash
sudo dnf install php-fpm
```

Poiché php-fpm è un servizio per il sistema, deve essere attivato e avviato:

```bash
sudo systemctl enable php-fpm
sudo systemctl start php-fpm
sudo systemctl status php-fpm
```

### Configurazione

Il file di configurazione principale è memorizzato in `/etc/php-fpm.conf`.

```bash
include=/etc/php-fpm.d/*.conf
[global]
pid = /run/php-fpm/php-fpm.pid
error_log = /var/log/php-fpm/error.log
daemonize = yes
```

!!! Note "Nota"

    I file di configurazione php-fpm sono ampiamente commentati. Andate a dare un'occhiata!

Come si può vedere, i file della cartella `/etc/php-fpm/` con estensione `.conf` sono sempre inclusi.

Per impostazione predefinita, un pool di processi PHP, chiamato `www`, è definito in `/etc/php-fpm.d/www.conf`.

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

#### Configurazione del modo di accedere ai processi di php-fpm

Configurazione del modo di accedere ai processi di php-fpm.

Tramite un'interfaccia inet come:

`listen = 127.0.0.1:9000`.

O tramite un socket Unix:

`listen = /run/php-fpm/www.sock`.

!!! Note "Nota"

    Utilizzando un socket quando il server web e il server PHP si trovano sulla stessa macchina, si elimina il livello TCP/IP e si ottimizzano le prestazioni.

Quando si opera tramite un'interfaccia, è necessario configurare `listen.owner`, `listen.group`, `listen.mode` per specificare il proprietario, il gruppo di proprietari e i diritti del socket Unix. **Attenzione:** entrambi i server (web e PHP) devono avere i diritti di accesso al socket.

Quando si lavora tramite un socket, è necessario configurare `listen.allowed_clients` per limitare l'accesso al server PHP a determinati indirizzi IP.

Esempio: `listen.allowed_clients = 127.0.0.1`

#### Configurazione statica o dinamica

I processi di PHP-FPM possono essere gestiti staticamente o dinamicamente.

In modalità statica, il numero di processi figli è impostato dal valore di `pm.max_children`;

```bash
pm = static
pm.max_children = 10
```

Questa configurazione avvierà 10 processi.

In modalità dinamica, PHP-FPM lancerà al massimo il numero di processi specificato dal valore di `pm.max_children`, iniziando a lanciare un numero di processi corrispondente a `pm.start_servers`, e mantenendo almeno il valore di `pm.min_spare_servers` di processi inattivi e al massimo `pm.max_spare_servers` di processi inattivi.

Esempio:

```bash
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

PHP-FPM creerà un nuovo processo per sostituire quello che ha elaborato un numero di richieste equivalente a `pm.max_requests`.

Per impostazione predefinita, `pm.max_requests` è impostato a 0, il che significa che i processi non vengono mai riciclati. L'uso dell'opzione `pm.max_requests` può essere interessante per applicazioni con problemi di memoria.

C'è una terza modalità di funzionamento, la modalità `ondemand`. Questa modalità avvia un processo solo quando riceve una richiesta. Non è una modalità ottimale per i siti con forti pressioni e deve essere riservata a esigenze specifiche (siti con richieste molto deboli, backend di gestione, ecc.).

!!! Note "Nota"

    La configurazione della modalità operativa di PHP-FPM è essenziale per garantire un funzionamento ottimale del server web.

#### Stato del processo

PHP-FPM offre, come Apache e il suo modulo `mod_status`, una pagina che indica lo stato del processo.

Per attivare la pagina, impostare il suo percorso di accesso tramite la direttiva `pm.status_path`:

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

La direttiva slowlog specifica il file che riceve la registrazione delle richieste troppo lunghe (cioè, il cui tempo supera il valore della direttiva `request_slowlog_timeout`).

La posizione predefinita del file generato è `/var/log/php-fpm/www-slow.log`.

```bash
request_slowlog_timeout = 5
slowlog = /var/log/php-fpm/www-slow.log
```

Un valore di 0 per `request_slowlog_timeout` disabilita la registrazione.

### Integrazione con NGinx

L'impostazione predefinita di nginx include già la configurazione necessaria per far funzionare PHP con PHP-FPM.

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

Affinché nginx possa elaborare i file `.php`, le seguenti direttive devono essere aggiunte al file di configurazione del sito:

Se PHP-FPM è in ascolto sulla porta 9000:

```bash
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass 127.0.0.1:9000;
}
```

Se php-fpm è in ascolto su un socket unix:

```bash
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass unix:/run/php-fpm/www.sock;
}
```

### Integrazione con Apache

La configurazione di apache per utilizzare un pool PHP è abbastanza semplice. È sufficiente usare i moduli proxy con una direttiva `ProxyPassMatch`, per esempio:

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

È essenziale ottimizzare il numero di richieste che potranno essere servite e analizzare la memoria utilizzata dagli script PHP, per ottimizzare la quantità massima di thread lanciati.

Prima di tutto, dobbiamo conoscere la quantità media di memoria utilizzata da un processo PHP, con il comando:

```bash
while true; do ps --no-headers -o "rss,cmd" -C php-fpm | grep "pool www" | awk '{ sum+=$1 } END { printf ("%d%s\n", sum/NR/1024,"Mb") }' >> avg_php_proc; sleep 60; done
```

Dopo un po' di tempo, questo dovrebbe darci un'idea abbastanza precisa dell'occupazione media di memoria di un processo PHP su questo server.

Per il resto di questo documento, diciamo che il risultato è un'impronta di memoria di 120 Mb per processo a pieno carico.

Su un server con 8 Gb di RAM, mantenendo 1 Gb per il sistema e 1 Gb per la OPCache (si veda il resto di questo documento), rimangono 6 Gb per elaborare le richieste PHP dei client.

Si può facilmente concludere che questo server può accettare al massimo **50 thread** `((6*1024) / 120)`.

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

Per configurarla, dobbiamo lavorare su:

* La dimensione della memoria dedicata alla opcache in base alla percentuale di successo, configurandola in modo corretto
* il numero di script PHP da memorizzare nella cache (numero di chiavi + numero massimo di script)
* il numero di stringhe da mettere in cache

Per installarla:

```bash
sudo dnf install php-opcache
```

Per configurarla, modificare il file di configurazione `/etc/php.d/10-opcache.ini`:

```bash
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
```

dove:

* `opcache.memory_consumption` corrisponde alla quantità di memoria necessaria per l'opcache (da aumentare fino a ottenere un corretto rapporto di successo).
* `opcache.interned_strings_buffer` la quantità di stringhe da mettere in cache.
* `opcache.max_accelerated_files` è prossimo al risultato del comando `find ./ -iname "*.php"|wc -l`.

Si può fare riferimento a una pagina `info.php` (compresa la funzione `phpinfo();`) per configurare l'opcache (vedi per esempio i valori di `Cached scripts` e `Cached strings`).

!!! Note "Nota"

    A ogni nuova distribuzione di nuovo codice, sarà necessario svuotare la opcache (ad esempio riavviando il processo php-fpm).

!!! Note "Nota"

    Non sottovalutate il guadagno di velocità che si può ottenere impostando e configurando correttamente l'opcache.
