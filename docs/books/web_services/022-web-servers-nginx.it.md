---
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
title: Part 2.2 Server Web Nginx
---

## Server web Nginx

In questo capitolo, imparerete a conoscere il server web Nginx.

****

**Obiettivi**: Imparerete a:

:heavy_check_mark: installare e configurare Nginx

:checkered_flag: **nginx**, **http**

**Competenze**: :star: :star:  
**Complessità**: :star: :star:

**Tempo di lettura**: 15 minuti

****

### Generalità

**Nginx** è un **server web HTTP gratuito con licenza BSD**. È stato sviluppato per la prima volta in Russia nel 2002 da Igor Sysoev. Oltre alle funzioni standard di un server web, Nginx fornisce un **reverse proxy** per il protocollo **HTTP** e un proxy per i protocolli di messaggistica **POP** e **IMAP**.

Lo sviluppo del server Nginx è una risposta al problema **C10K**, che supporta diecimila connessioni contemporanee (standard nel moderno web). Questa è una vera sfida per i server web.

Il supporto commerciale è fornito da Nginx Inc.

L'architettura interna del server consente **prestazioni molto elevate** con **basso consumo di memoria** rispetto al server web Apache.

I moduli che completano le funzioni essenziali del kernel Nginx sono vincolati in fase di compilazione. Ciò significa che l'attivazione o la disattivazione non possono avvenire in modo dinamico.

Un processo master controlla i processi del server, rendendo possibile **modificare la configurazione o aggiornare il software senza arrestare il servizio**.

Nginx ha una quota di mercato significativa del 28% sui siti più trafficati, subito dopo Apache (41%).

#### Caratteristiche

Nginx offre le seguenti funzioni di base:

- Hosting per pagine web statiche
- Index page generation automatico
- Reverse proxy accelerato con cache
- Bilanciamento del carico
- Tolleranza agli errori
- Supporto cache per FastCGI, uWSGI, SCGI e server cache Memcached
- Vari filtri per gzip, xslt, ssi, trasformazione delle immagini e altro ancora
- Supporto per SSL/TLS e SNI
- Supporto per HPPT/2

Altre funzionalità:

- Hosting per nome o indirizzo IP
- Supporto del Keepalive delle connessioni client
- Gestione dei log: syslog, rotazione, buffer
- Riscrittura degli URI
- Controllo di accesso: via IP, password, ed altro
- Streaming FLV e MP4

### Installazione

Nginx è disponibile direttamente dal repository di app stream e le versioni più recenti sono disponibili come modulo dnf.

```bash
sudo dnf install nginx
sudo systemctl enable nginx --now
```

### Configurazione

Il path del file di configurazione di Nginx è `/etc/nginx/nginx.conf`.

Questo file di configurazione è un file di configurazione generale del server. Ossia le impostazioni hanno effetto sull'intero server.

!!! NOTE "Nota"

```
La funzionalità del file .htaccess nota agli amministratori di Apache non esiste in Nginx!
```

Qui viene fornito il file \`nginx.conf', privato di tutti i commenti:

```bash
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
include /usr/share/nginx/modules/*.conf;
events {
    worker_connections 1024;
}
http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;
    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;
    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;
    include /etc/nginx/conf.d/*.conf;
    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;
        include /etc/nginx/default.d/*.conf;
        error_page 404 /404.html;
        location = /404.html {
        }
        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
}
```

Linee guida per la configurazione di default:

| Direttiva                   | Descrizione                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| --------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `user`                      | Definisce il proprietario del processo `user` e `group`. Se il gruppo non è specificato, viene utilizzato il gruppo con lo stesso nome dell'utente.                                                                                                                                                                                                                                                                       |
| `worker_processes`          | Definisce il numero di processi. Il valore ottimale dipende da molti fattori, come il numero di core della CPU e le specifiche del disco rigido. In caso di dubbio, la documentazione di Nginx suggerisce un valore iniziale equivalente al numero di core disponibili della CPU  (il auto value cercherà di determinarlo).                                                            |
| `pid`                       | Definisce un file per memorizzare il valore PID.                                                                                                                                                                                                                                                                                                                                                                                          |
| `worker_connections`        | Imposta il numero massimo di connessioni simultanee che un processo worker può aprire (verso il client e i server mandatari).                                                                                                                                                                                                                                                                                          |
| `tcp_nopush`                | `tcp_nopush` è inseparabile dall'opzione sendfile. Viene utilizzato per ottimizzare la quantità di informazioni inviate simultaneamente. I pacchetti vengono inviati solo quando hanno raggiunto la loro dimensione massima.                                                                                                                                                                              |
| `tcp_nodelay`               | L'attivazione di `tcp_nodelay` forza l'invio immediato dei dati nel socket, indipendentemente dalla dimensione del pacchetto, che è l'opposto di ciò che fa `tcp_nopush`.                                                                                                                                                                                                                                                                 |
| `sendfile`                  | Ottimizza l'invio di file statici (questa opzione non è necessaria per una configurazione proxy-inverse). Se sendfile è abilitato, Nginx si assicura che tutti i pacchetti siano riempiti prima di essere inviati al client (grazie a `tcp_nopush`). Quando arriva l'ultimo pacchetto, Nginx disabilita `tcp_nopush` e forza l'invio dei dati usando `tcp_nodelay`. |
| `keepalive_timeout`         | Il tempo massimo prima di chiudere una connessione inattiva.                                                                                                                                                                                                                                                                                                                                                                              |
| `types_hash_max_size`       | Nginx mantiene tabelle hash contenenti informazioni statiche. Imposta la dimensione massima della tabella hash.                                                                                                                                                                                                                                                                                                           |
| `include`                   | Include uno o più file che corrispondono al modello fornito nella configurazione.                                                                                                                                                                                                                                                                                                                                                         |
| `default_type`              | MIME e' il type predefinito di una richiesta.                                                                                                                                                                                                                                                                                                                                                                                             |
| `ssl_protocols`             | Versioni del protocollo TLS accettate.                                                                                                                                                                                                                                                                                                                                                                                                    |
| `ssl_prefer_server_ciphers` | Preferisce la suite di cifratura del server alla suite di cifratura del client.                                                                                                                                                                                                                                                                                                                                                           |
| `access_log`                | Configura i log di accesso (vedere il paragrafo “Gestione dei log”).                                                                                                                                                                                                                                                                                                                                                   |
| `error_log`                 | Configura i log degli errori (vedere il paragrafo “Gestione dei log”).                                                                                                                                                                                                                                                                                                                                                 |
| `gzip`                      | Il modulo ngx_http_gzip_module è un filtro che comprime i dati trasmessi in formato gzip.                                                                                                                                                                                                                                                                                  |
| `gzip_disable`              | Disabilita gzip in base a una regular expression.                                                                                                                                                                                                                                                                                                                                                                                         |

La struttura della configurazione di Nginx è:

```text
# global directives

events {
    # worker configuration
}

http {
    # http service configuration

    # Configure the first server listening on port 80
    server {
        listen 80 default_server;
        listen [::]:80 default_server;
        root /var/www/html;
        index index.html index.htm;
        server_name _;
        location / {
            try_files $uri $uri/ =404;
        }
    }
}

mail {
    # mail service configuration

# global mail service directives
   server {
        # A first server listening on the pop protocol
        listen     localhost:110;
        protocol   pop3;
        proxy      on;
   }


   server {
        # A second server listening on the imap protocol
       listen     localhost:143;
       protocol   imap;
       proxy      on;
   }
}
```

### Configurazione HTTPS

Per configurare un servizio HTTPS, è necessario aggiungere un server block o modificarne uno esistente. Un server block può essere in ascolto sia sulla porta 443 che sulla porta 80.

Si può aggiungere questo blocco, ad esempio, al nuovo file `/etc/nginx/conf.d/default_https.conf`:

```bash
server {
    listen              443 ssl default_server;
    ssl_protocols       TLSv1.3 TLSv1.2 TLSv1.1
    ssl_certificate     /path/to/cert.pem;
    ssl_certificate_key /path/to/key.key;
    root                /var/www/html;
    index               index.html index.htm;
    server_name         _;
    location / {
        try_files       $uri $uri/ =404;
    }
}
```

oppure si può modificare il server predefinito per supportare HTTPS:

```bash
server {
    listen              80;
    listen              443 ssl;
    server_name         _;
    ssl_protocols       TLSv1.3 TLSv1.2 TLSv1.1
    ssl_certificate     /path/to/cert.pem;
    ssl_certificate_key /path/to/key.key;
    ...
}
```

### Gestione del log

È possibile configurare la direttiva `error_log` per i log degli errori.

La sintassi della direttiva `error_log` è:

```bash
error_log file [level];
```

Il primo parametro definisce un file per ricevere i log degli errori.

Il secondo parametro determina il livello di log: debug, info, notice, warn, error, crit, alert o emerg (vedere il capitolo syslog della nostra guida all'amministrazione).

La funzione di invio dei log a syslog avviene con il prefisso “syslog:”.

```bash
access_log syslog:server=192.168.1.100:5514,tag=nginx debug;
```

### Nginx come server proxy

La funzionalità di reverse proxy è compreso nel modulo `ngx_http_upstream_module`. Permette di definire gruppi di server che vengono poi chiamati dalle direttive `proxy_pass` o `fastcgi_pass`, `memcached_pass` e altro.

Esempio di configurazione di base, che distribuisce il carico per 2/3 al primo server e per 1/3 al secondo application server:

```bash
    upstream frontservers {
        server front1.rockylinux.lan:8080       weight=2;
        server front2.rockylinux.lan:8080       weight=1;
    }

    server {
        location / {
            proxy_pass http://docs.rockylinux.lan;
        }
    }
```

È possibile dichiarare i server come backup:

```bash
    upstream frontservers {
        ...
        server front3.rockylinux.lan:8080   backup;
        server front4.rockylinux.lan:8080   backup;
    }
```

La direttiva server accetta molti argomenti:

- `max_fails=numberofattempts`: imposta il numero di tentativi di connessione che devono fallire durante il periodo di tempo definito dal parametro `fail_timeout` affinché il server sia considerato non disponibile. Il valore predefinito è 1; 0 disattiva la funzionalità.
- `fail_timeout=time`: imposta il tempo durante il quale un numero definito di connessioni causerà l'indisponibilità del server e imposta il periodo di tempo durante il quale il server sarà considerato non disponibile. Il valore predefinito è 10 secondi.
