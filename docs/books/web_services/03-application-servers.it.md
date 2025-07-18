---
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
title: Capitolo 3. Server applicativi
tags:
  - web
  - php
  - php-fpm
  - application server
  - dynamic language
---

## PHP e PHP-FPM

In questo capitolo, si potranno apprendere le caratteristiche di PHP e PHP-FPM.

**PHP** (**P**HP **H**ypertext **P**reprocessor) è un linguaggio di source scripting appositamente progettato per lo sviluppo di applicazioni web. Nel 2024, PHP rappresentava poco meno dell'80% delle pagine web generate nel mondo. PHP è open-source ed è il cuore dei più famosi CMS (WordPress, Drupal, Joomla!, Magento e altri).

**PHP-FPM** (**F**astCGI **P**rocess **M**anager) è integrato in PHP dalla versione 5.3.3. La versione FastCGI di PHP offre ulteriori funzionalità.

****

**Obiettivi**: si imparerà come:

:heavy_check_mark: installare un application server PHP\
:heavy_check_mark: configurare il pool PHP-FPM\
:heavy_check_mark: ottimizzare un server di applicazioni PHP-FPM

:checkered_flag: **PHP**, **PHP-FPM**, **Server applicativo**

**Conoscenza**: :star: :star: :star:\
**Complessità**: :star: :star: :star:

**Tempo di lettura**: 30 minuti

****

### Generalità

**CGI** (**C**ommon **G**ateway **I**nterface) e **FastCGI** permettono la comunicazione tra il server web (Apache o Nginx) e un linguaggio di sviluppo (PHP, Python, Java):

- Nel caso di **CGI**, ogni richiesta crea un **nuovo processo**, il che è meno efficiente in termini di prestazioni.
- **FastCGI** si affida a un **certo numero di processi** per trattare le richieste dei clienti.

PHP-FPM, **oltre a prestazioni migliori**, porta:

- La possibilità di un migliore **partizionamento delle applicazioni**: lancio di processi con uid/gid diversi, con file `php.ini` personalizzati,
- La gestione delle statistiche,
- Gestione del registro,
- Gestione dinamica dei processi e riavvio senza interruzione del servizio ('graceful').

!!! Note

```
Poiché Apache ha un modulo PHP, php-fpm è più comunemente usato su un server Nginx.
```

### Scegliere una versione PHP

Rocky Linux, come il suo upstream, offre molte versioni del linguaggio. Alcuni di essi hanno raggiunto la fine del loro ciclo di vita, ma vengono mantenuti per continuare a ospitare applicazioni storiche che non sono ancora compatibili con le nuove versioni di PHP. Fare riferimento alla pagina [versioni supportate](https://www.php.net/supported-versions.php) del sito php.net per scegliere una versione supportata.

Per ottenere un elenco delle versioni disponibili, digitate il seguente comando:

\=== "Elenco dei moduli PHP 9.3"

```bash
$ sudo dnf module list php

Rocky Linux 9 - AppStream
Name                                                 Stream                                                  Profiles                                                                   Summary
php                                                  8.1 [d]                                                 common [d], devel, minimal

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

Il repository Remi offre versioni più recenti di PHP rispetto al repository Appstream, tra cui le versioni 8.2 e 8.3.

Per installare il repository Remi, eseguire il seguente comando:

```bash
sudo dnf install https://rpms.remirepo.net/enterprise/remi-release-9.rpm
```

Abilitare la repository Remi eseguendo il seguente comando:

```bash
sudo dnf config-manager --set-enabled remi
```

È ora possibile attivare un modulo più recente (PHP 8.3) immettendo il seguente comando:

```bash
sudo dnf module enable php:remi-8.3
```

\=== "Elenco dei moduli PHP 8.9"

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

Rocky fornisce diversi moduli PHP dal suo repository AppStream.

Noterete che la versione predefinita di Rocky 8.9 è la 7.2, che ha già raggiunto il suo limite di vita al momento in cui scriviamo.

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

### Installazione della PHP CGI mode

Innanzitutto, installate e utilizzate PHP in CGI mode. Può funzionare solo con il server web Apache e il suo modulo `mod_php`. La sezione FastCGI di questo documento (php-fpm) spiega come integrare PHP in Nginx (ma anche in Apache).

L'installazione di PHP è relativamente banale. Consiste nell'installare il pacchetto principale e i pochi moduli necessari.

L'esempio seguente installa PHP con i moduli normalmente installati con esso.

\=== "9.3 installare PHP"

```bash
sudo dnf install php php-cli php-gd php-curl php-zip php-mbstring
```

Durante l'installazione, verrà richiesto di importare le chiavi GPG per i repository epel9 (Extra Packages for Enterprise Linux 9) e Remi. Immettere y per importare le chiavi:

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

\=== "8.9 installare PHP"

```bash
sudo dnf install php php-cli php-gd php-curl php-zip php-mbstring
```

È possibile verificare che la versione installata corrisponda a quella prevista:

\=== "9.3 controllare la versione di PHP"

```bash
$ php -v
PHP 8.3.2 (cli) (built: Jan 16 2024 13:46:41) (NTS gcc x86_64)
Copyright (c) The PHP Group
Zend Engine v4.3.2, Copyright (c) Zend Technologies
with Zend OPcache v8.3.2, Copyright (c), by Zend Technologies
```

\=== "8.9 controllare la versione di PHP"

```bash
$ php -v
PHP 7.4.19 (cli) (built: May  4 2021 11:06:37) ( NTS )
Copyright (c) The PHP Group
Zend Engine v3.4.0, Copyright (c) Zend Technologies
with Zend OPcache v7.4.19, Copyright (c), by Zend Technologies
```

### Apache Integration

Per servire pagine PHP in modalità CGI, è necessario installare il server Apache, configurarlo, attivarlo e avviarlo.

- Installazione:

```bash
sudo dnf install httpd
```

```
attivazione:
```

```bash
sudo systemctl enable --now httpd
sudo systemctl status httpd
```

- Non dimenticate di configurare il firewall:

```bash
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --reload
```

Il vhost predefinito dovrebbe funzionare subito. PHP fornisce una funzione `phpinfo()` che genera una tabella riassuntiva della sua configurazione. È utile per verificare se il PHP funziona bene. Tuttavia, fate attenzione a non lasciare tali file di prova sui vostri server. Rappresentano un enorme rischio per la sicurezza della vostra infrastruttura.

Creare il file `/var/www/html/info.php` (`/var/www/html` è la cartella vhost della configurazione predefinita di Apache):

```bash
< ?php
phpinfo();
?>
```

Verificare con un browser web il corretto funzionamento del server accedendo alla pagina [http://your-server-ip/info.php](http://your-server-ip/info.php).

!!! Warning "Attenzione"

```
Non lasciare il file `info.php` sul server!
```

### Installazione della CGI mode di PHP  (PHP-FPM)

Come già detto, ci sono molti vantaggi nel passare l'hosting web alla modalità PHP-FPM.

L'installazione comporta solo il pacchetto php-fpm:

```bash
sudo dnf install php-fpm
```

Poiché php-fpm è un servizio dal punto di vista del sistema, è necessario attivarlo e avviarlo:

```bash
sudo systemctl enable php-fpm
sudo systemctl start php-fpm
sudo systemctl status php-fpm
```

#### Configurazione del CGI mode di PHP

Il file di configurazione principale è `/etc/php-fpm.conf`.

```bash
include=/etc/php-fpm.d/*.conf
[global]
pid = /run/php-fpm/php-fpm.pid
error_log = /var/log/php-fpm/error.log
daemonize = yes
```

!!! Note

```
I file di configurazione di php-fpm sono ampiamente commentati. Andate a dare un'occhiata!
```

Come si può vedere, i file della cartella `/etc/php-fpm.d/` con estensione `.conf` sono sempre inclusi.

Per impostazione predefinita, la dichiarazione di un pool di processi PHP chiamato `www` è presente in `/etc/php-fpm.d/www.conf`.

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
| `listen`   | Definisce l'interfaccia di ascolto o il socket Unix utilizzato.                                                                                                                             |

#### Configurazione del modo di accedere ai processi di php-fpm

Esistono due modi per collegarsi.

Con una `inet-interface` come:

`listen = 127.0.0.1:9000`.

O con un socket UNIX:

`listen = /run/php-fpm/www.sock`.

!!! Note

```
L'uso di un socket quando il server web e il server PHP si trovano sulla stessa macchina elimina il livello TCP/IP e ottimizza le prestazioni.
```

Quando si lavora con un'interfaccia, è necessario configurare `listen.owner`, `listen.group`, `listen.mode` per specificare il proprietario, il gruppo di proprietari e i diritti del socket UNIX. **Attenzione:** Entrambi i server (web e PHP) devono avere i diritti di accesso al socket.

Quando si lavora con un socket, è necessario configurare `listen.allowed_clients` per limitare l'accesso al server PHP a determinati indirizzi IP.

Esempio: `listen.allowed_clients = 127.0.0.1`

#### Configurazione statica o dinamica

È possibile gestire i processi PHP-FPM in modo statico o dinamico.

In modalità statica, `pm.max_children` imposta un limite al numero di processi child:

```bash
pm = static
pm.max_children = 10
```

Questa configurazione si avvia con 10 processi.

In modalità dinamica, PHP-FPM avvia al massimo il numero di processi specificato dal valore` pm.max_children`. Avvia prima alcuni processi corrispondenti a `pm.start_servers`, mantenendo almeno il valore di `pm.min_spare_servers` dei processi inattivi e, al massimo, `pm.max_spare_servers` dei processi inattivi.

Esempio:

```bash
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

PHP-FPM creerà un nuovo processo per sostituire quello che ha elaborato più richieste equivalenti a `pm.max_requests`.

Per impostazione predefinita, il valore di `pm.max_requests` è 0, il che significa che i processi non vengono mai riciclati. L'opzione `pm.max_requests` può essere interessante per le applicazioni con leaks di memoria.

Una terza modalità di funzionamento è la modalità `ondemand`. Questa modalità avvia un processo solo quando riceve una richiesta. Non è una modalità ottimale per i siti con forti influenze ed è riservata a esigenze specifiche (siti con richieste deboli, backend gestionale, ecc.).

!!! Note

```
La configurazione della modalità operativa di PHP-FPM è essenziale per garantire il funzionamento ottimale del server web.
```

#### Stato del processo

Come Apache e il suo modulo `mod_status`, PHP-FPM offre una pagina che indica lo stato del processo.

Per attivare la pagina, impostare il suo path nella directive `pm.status_path`:

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

La direttiva `slowlog` specifica il file che riceve le richieste di registrazione troppo lunghe (per esempio, il cui tempo supera il valore della direttiva `request_slowlog_timeout`).

La posizione predefinita del file generato è `/var/log/php-fpm/www-slow.log`.

```bash
request_slowlog_timeout = 5
slowlog = /var/log/php-fpm/www-slow.log
```

Un valore di 0 per `request_slowlog_timeout` disabilita la registrazione.

### Integrazione con NGinx

L'impostazione predefinita di nginx include già la configurazione necessaria per far funzionare PHP con PHP-FPM.

Il file di configurazione `fastcgi.conf` (o `fastcgi_params`) si trova sotto `/etc/nginx/`:

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

Per far sì che nginx elabori i file `.php`, aggiungere le seguenti directive al file di configurazione del sito:

Se PHP-FPM è in ascolto sulla porta 9000:

```bash
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass 127.0.0.1:9000;
}
```

Se php-fpm è in ascolto su un socket UNIX:

```bash
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass unix:/run/php-fpm/www.sock;
}
```

### Integrazione con Apache

La configurazione di apache per utilizzare un pool PHP è abbastanza semplice. È necessario utilizzare i moduli proxy con una directive `ProxyPassMatch`, per esempio:

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

L'ottimizzazione del numero di richieste servite e l'analisi della memoria utilizzata dagli script PHP sono necessarie per massimizzare il numero di thread lanciati.

Prima di tutto, è necessario conoscere la quantità media di memoria utilizzata da un processo PHP con il comando:

```bash
while true; do ps --no-headers -o "rss,cmd" -C php-fpm | grep "pool www" | awk '{ sum+=$1 } END { printf ("%d%s\n", sum/NR/1024,"Mb") }' >> avg_php_proc; sleep 60; done
```

Questo vi darà un'idea abbastanza precisa dell'ingombro medio della memoria di un processo PHP su questo server.

Il resto di questo documento comporta un ingombro di memoria di 120 MB per processo a pieno carico.

Su un server con 8Gb di RAM, mantenendo 1Gb per il sistema e 1Gb per la OPCache (vedere il resto di questo documento), rimangono 6Gb per elaborare le richieste PHP dei client.

Si può concludere che questo server può accettare al massimo **50 thread** `((6*1024) / 120)`.

Una configurazione modello di `php-fpm` specifica per questo caso d'uso è:

```bash
pm = dynamic
pm.max_children = 50
pm.start_servers = 12
pm.min_spare_servers = 12
pm.max_spare_servers = 36
pm.max_requests = 500
```

con:

- `pm.start_servers` = 25% di `max_children`
- `pm.min_spare_servers` = 25% di `max_children`
- `pm.max_spare_servers` = 75% di `max_children`

### Configurazione di Opcache

La `opcache` (Optimizer Plus Cache) è il primo livello di cache su cui si può intervenire.

Mantiene gli script PHP compilati in memoria, il che ha un forte impatto sull'esecuzione delle pagine web (elimina la lettura su disco degli script + il tempo di compilazione).

Per configurarlo, è necessario lavorare su:

- La dimensione della memoria dedicata alla opcache in base all'hit ratio, configurandola correttamente
- Il numero di script PHP da memorizzare nella cache (numero di chiavi + numero massimo di script)
- Il numero di stringhe da mettere in cache

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

Dove:

- `opcache.memory_consumption` corrisponde alla quantità di memoria necessaria per l'opcache (aumentarla fino a ottenere un rapporto di hit corretto).
- `opcache.interned_strings_buffer` è la quantità di stringhe da mettere in cache.
- `opcache.max_accelerated_files` è vicino al risultato del comando `find ./ -iname “*.php”|wc -l`.

Per configurare l'opcache, fare riferimento a una pagina `info.php` (compresa la `phpinfo();`) (si vedano, per esempio, i valori di `Cached scripts` e `Cached strings`).

!!! Note

```
A ogni nuova distribuzione di nuovo codice, sarà necessario svuotare la opcache (ad esempio riavviando il processo php-fpm).
```

!!! Note

```
Non sottovalutate l'aumento di velocità che si può ottenere impostando e configurando correttamente l'opcache.
```

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
