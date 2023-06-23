---
title: PHP e PHP-FPM
author: Antoine Le Morvan
contributors: Steven Spencer, Franco Colussi
tested_with: 8.5
tags:
  - web
  - php
  - php-fpm
---

# PHP e PHP-FPM

**PHP** (**P**HP **H**ypertext **P**reprocessor) è un linguaggio sorgente di scripting, appositamente progettato per lo sviluppo di applicazioni web. Nel 2021, PHP rappresentava poco meno dell'80% delle pagine web generate nel mondo. PHP è open-source ed è il nucleo dei più famosi CMS (WordPress, Drupal, Joomla!, Magento, ...).

**PHP-FPM** (**F**astCGI **P**rocess **M**anager) è integrato nel PHP dalla sua versione 5.3.3. La versione FastCGI di php porta funzionalità aggiuntive.

## Generalità

**CGI** (**C**ommon **G**ateway **I**nterface) e **FastCGI** permettono la comunicazione tra il server web (Apache, Nginx, ...) e un linguaggio di sviluppo (Php, Python, Java):

* Nel caso di **CGI**, ogni richiesta porta alla creazione di un **nuovo processo**, che è meno efficiente in termini di prestazioni.
* **FastCGI** si basa su un **certo numero di processi** per il trattamento delle sue richieste client.

PHP-FPM, **oltre a migliori prestazioni**, porta:

* La possibilità di una migliore **separazione delle applicazioni**: lanciare processi con uid/gid diversi, con file php.ini personalizzati,
* La gestione delle statistiche,
* Gestione del registro,
* Gestione dinamica dei processi e riavvio senza interruzione del servizio ('graceful').

!!! Note "Nota"

    Poiché Apache ha un modulo php, l'uso di php-fpm è più comunemente usato su un server Nginx.

## Scegliere una versione php

Rocky Linux, come il suo upstream, offre molte versioni del linguaggio. Alcune di esse hanno raggiunto la fine della loro vita ma sono mantenute per continuare ad ospitare applicazioni storiche che non sono ancora compatibili con le nuove versioni di PHP. Si prega di fare riferimento alla pagina [ versioni supportate ](https://www.php.net/supported-versions.php) del sito web php.net per scegliere una versione supportata.

Per ottenere un elenco delle versioni disponibili, basta inserire il seguente comando:

```
$ sudo dnf module list php
Rocky Linux 8 - AppStream
Name         Stream          Profiles                           Summary                       
php          7.2 [d]         common [d], devel, minimal         PHP scripting language        
php          7.3             common [d], devel, minimal         PHP scripting language        
php          7.4             common [d], devel, minimal         PHP scripting language        

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

Rocky fornisce, dal proprio repository AppStream, diversi moduli PHP.

Noterete che la versione predefinita di un Rocky 8.5 è la 7.2, che ha già raggiunto la sua fine vita al momento in cui scriviamo.

Puoi attivare un nuovo modulo inserendo il seguente comando:

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

!!! Note "Nota"

    Al momento non è possibile installare php 8 dai repository di AppStream. Per questo, dovrai passare attraverso il repository REMI. Questa installazione non è contemplata nel presente documento.

Ora è possibile procedere all'installazione del motore php.

## Modalità PHP cgi

In primo luogo, vediamo come installare e utilizzare php nella sua modalità CGI. Saremo in grado di farlo funzionare solo con il server web Apache e il suo modulo `mod_php`. Vedremo più tardi in questo documento, nella parte FastCGI (php-fpm) come integrare PHP in Nginx (ma anche in Apache).

### Installazione

L'installazione di php è abbastanza banale, dal momento che consiste nell'installare il pacchetto principale così come i pochi moduli php di cui avrete bisogno.

L'esempio qui sotto installa php con i moduli che sono normalmente installati con esso.

```
$ sudo dnf install php php-cli php-gd php-curl php-zip php-mbstring
```

È possibile verificare che la versione installata corrisponda a quella prevista:

```
$ php -v
PHP 7.4.19 (cli) (built: May  4 2021 11:06:37) ( NTS )
Copyright (c) The PHP Group
Zend Engine v3.4.0, Copyright (c) Zend Technologies
    with Zend OPcache v7.4.19, Copyright (c), by Zend Technologies
```

### Configurazione

### Integrazione con Apache

Per servire le pagine php in modalità cgi, dovrai installare il server apache, configurarlo, attivarlo e avviarlo.

* Installazione:

```
$ sudo dnf install httpd
```

* Attivazione:

```
$ sudo systemctl enable httpd
$ sudo systemctl start httpd
$ sudo systemctl status httpd
```

* Non dimenticarti di configurare il firewall:

```
$ sudo firewall-cmd --add-service=http --permanent
$ sudo firewall-cmd --reload
```

Il vhost predefinito dovrebbe funzionare fuori dalla scatola. PHP fornisce una funzione `phpinfo()` che genera una tabella riassuntiva della sua configurazione. È molto utile per testare il buon funzionamento di php. Tuttavia, fate attenzione a non lasciare questi file di prova in giro sui vostri server, rappresentano un enorme rischio per la sicurezza della vostra infrastruttura.

Crea il file `/var/www/html/info.php` (essendo la directory vhost predefinita della configurazione predefinita di apache `/var/www/html`):

```
<?php
phpinfo();
?>
```

Usa un browser web per verificare che il server funzioni correttamente andando alla pagina http://your-server-ip/info.php.

!!! Warning "Attenzione"

    Non lasciare il file info.php sul vostro server!

## PHP-FPM (FastCGI)

Come abbiamo sottolineato in precedenza in questo documento, ci sono molti vantaggi per passare al web hosting in modalità php-fpm.

### Installazione

L'installazione è limitata al pacchetto php-fpm:

```
$ sudo dnf install php-fpm
```

Poiché php-fpm è un servizio dal punto di vista del sistema, deve essere attivato e avviato:

```
$ sudo systemctl enable php-fpm
$ sudo systemctl start php-fpm
$ sudo systemctl status php-fpm
```

### Configurazione

Il file di configurazione principale è memorizzato in `/etc/php-fpm.conf`.

```
include=/etc/php-fpm.d/*.conf
[global]
pid = /run/php-fpm/php-fpm.pid
error_log = /var/log/php-fpm/error.log
daemonize = yes
```

!!! Note "Nota"

    I file di configurazione php-fpm sono ampiamente commentati. Andate a dare un'occhiata!

Come puoi vedere, i file con l'estensione `.conf` nella directory `/etc/php-fpm/` sono sempre inclusi.

Per impostazione predefinita, un pool di processi php, denominato `www`, è dichiarato in `/etc/php-fpm.d/www.conf`.

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

| Istruzioni | Descrizione                                                                                                                                                     |
| ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `[pool]`   | Nome del pool di processi. Il file di configurazione può essere composto da diversi pool di processi (il nome del pool tra parentesi inizia una nuova sezione). |
| `listen`   | Definisce l'interfaccia di ascolto o il socket unix utilizzato.                                                                                                 |

#### Configurare il modo di accedere ai processi php-fpm

Ci sono 2 modi per connettersi.

Tramite un'interfaccia di inet come:

`listen = 127.0.0.1:9000`.

Oppure attraverso un socket Unix:

`listen = /run/php-fpm/www.sock`.

!!! Note "Nota"

    L'uso di un socket quando il server web e il server php sono sulla stessa macchina permette la rimozione del livello TCP/IP e ottimizza le prestazioni.

Quando si lavora tramite un'interfaccia, bisogna configurare `listen.owner`, `listen.group`, `listen.mode` per specificare il proprietario, il gruppo proprietario e i diritti del socket Unix. **Attenzione:** entrambi i server (web e php) devono avere diritti di accesso sul socket.

Quando si lavora tramite un socket, bisogna configurare `listen.allowed_clients` per limitare l'accesso al server php a certi indirizzi IP.

Esempio: `listen.allowed_clients = 127.0.0.1`

#### Configurazione statica o dinamica

I processi di php-fpm possono essere gestiti staticamente o dinamicamente.

In modalità statica, il numero di processi figli è impostato dal valore di `pm.max_children`;

```
pm = static
pm.max_children = 10
```

Questa configurazione avvierà 10 processi.

In modalità dinamica, PHP-FPM lancerà al massimo il numero di processi specificato dal valore di `pm.max_children`, iniziando a lanciare un numero di processi corrispondente a `pm.start_servers`, e mantenendo almeno il valore di `pm.min_spare_servers` di processi inattivi e al massimo `pm.max_spare_servers` processi inattivi.

Esempio:

```
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

PHP-FPM creerà un nuovo processo per sostituire uno che ha processato un numero di richieste equivalente a `pm.max_requests`.

Per impostazione predefinita, `pm.max_requests` è impostato a 0, il che significa che i processi non vengono mai riciclati. L'uso dell'opzione `pm.max_requests` può essere interessante per applicazioni con perdite di memoria.

C'è una terza modalità di funzionamento, la modalità `ondemand`. Questa modalità avvia un processo solo quando riceve una richiesta. Non è una modalità ottimale per i siti con forti influenze, ed è da riservare per esigenze specifiche (siti con richieste molto deboli, backend di gestione, ecc.).

!!! Note "Nota"

    La configurazione della modalità operativa di PHP-FPM è essenziale per garantire un funzionamento ottimale del server web.


#### Stato del processo

PHP-FPM offre, come Apache e il suo modulo `mod_status`, una pagina che indica lo stato del processo.

Per attivare la pagina, impostare il suo percorso di accesso tramite la direttiva `pm.status_path`:

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

#### Registrazione di richieste lunghe

La direttiva slowlog specifica il file che riceve la registrazione delle richieste troppo lunghe (cioè, il cui tempo supera il valore della direttiva `request_slowlog_timeout`).

La posizione predefinita del file generato è `/var/log/php-fpm/www-slow.log`.

```
request_slowlog_timeout = 5
slowlog = /var/log/php-fpm/www-slow.log
```

Un valore di 0 per `request_slowlog_timeout` disabilita la registrazione.

### Integrazione con NGinx

L'impostazione predefinita di nginx include già la configurazione necessaria per far funzionare php con PHP-FPM.

Il file di configurazione `fastcgi.conf` (o `fastcgi_params`) si trova sotto `/etc/nginx/`:

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

Affinché nginx possa elaborare i file `.php`, le seguenti direttive devono essere aggiunte al file di configurazione del sito:

Se php-fpm è in ascolto sulla porta 9000:

```
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass 127.0.0.1:9000;
}
```

Se php-fpm è in ascolto su un socket unix:

```
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass unix:/run/php-fpm/www.sock;
}
```

### Integrazione con Apache

La configurazione di apache per utilizzare un pool php è abbastanza semplice. Basta usare i moduli proxy con una direttiva `ProxyPassMatch`, per esempio:

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

### Configurazione consistente dei pool php

È essenziale, per ottimizzare la quantità di richieste che potranno essere servite, analizzare la memoria utilizzata dagli script php e quindi ottimizzare la quantità massima di thread lanciati.

Prima di tutto, dobbiamo conoscere la quantità media di memoria utilizzata da un processo PHP, con il comando:

```
while true; do ps --no-headers -o "rss,cmd" -C php-fpm | grep "pool www" | awk '{ sum+=$1 } END { printf ("%d%s\n", sum/NR/1024,"Mb") }' >> avg_php_proc; sleep 60; done
```

Dopo un po', questo dovrebbe darci un'idea abbastanza precisa dell'impronta di memoria media di un processo php su questo server.

Per il resto di questo documento, diciamo che il risultato è un'impronta di memoria di 120 Mb per processo a pieno carico.

Su un server con 8Gb di RAM, conservando 1Gb per il sistema e 1Gb per la OPCache (vedi il resto di questo documento), rimangono 6Gb per elaborare le richieste PHP dei clienti.

Possiamo facilmente concludere che questo server può accettare al massimo **50 thread** `((6*1024) / 120)`.

Una buona configurazione di `php-fpm` specifica per questo caso di utilizzo sarebbe:

```
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

La `opcache` (Optimizer Plus Cache) è il primo livello di cache su cui possiamo influire.

Mantiene in memoria gli script php compilati, il che ha un forte impatto sull'esecuzione delle pagine web (elimina la lettura su disco dello script + il tempo di compilazione).

Per configurarla, dobbiamo lavorare su:

* La dimensione della memoria dedicata all'opcache in base al rapporto di hit

Configurando correttamente





* il numero di script php da mettere in cache (numero di chiavi + numero massimo di script)
* il numero di stringhe da mettere in cache

Per installarla:

```
$ sudo dnf install php-opcache
```

Per configurarla, modificare il file di configurazione `/etc/php.d/10-opcache.ini`:

```
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
```

dove:

* `opcache.memory_consumption` corrisponde alla quantità di memoria necessaria per l'opcache (da aumentare fino a ottenere un corretto rapporto di successo).
* `opcache.interned_strings_buffer` la quantità di stringhe da mettere in cache.
* `opcache.max_accelerated_files` è vicino al risultato del comando `find ./ -iname "*.php"|wc -l`.

Puoi fare riferimento alla pagina `info.php` (incluso il `phpinfo();`) per configurare l'opcache (vedi per esempio i valori di `Cached scripts` e `Cached strings`).

!!! Note "Nota"

    Ad ogni nuovo inserimento di nuovo codice, sarà necessario svuotare l'opcache (per esempio riavviando il processo php-fpm).

!!! Note "Nota"

    Non sottovalutate il guadagno di velocità che si può ottenere impostando e configurando correttamente l'opcache.
