---
title: HAProxy-Apache-LXD
author: Spencer Steven
contributors: Ezequiel Bruni, Antoine Le Morvan, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
---

# HAProxy bilanciamento del carico di Apache con i container LXD

## Introduzione

HAProxy sta per "High Availability Proxy" Questo proxy può essere collocato prima di qualsiasi applicazione TCP (come i server web), ma viene spesso utilizzato come bilanciatore di carico tra molte istanze di siti web.


Le ragioni possono essere molteplici. Se avete un sito web che viene visitato in modo intenso, l'aggiunta di un'altra istanza dello stesso sito web e l'inserimento di HAProxy in entrambe le istanze vi consente di distribuire il traffico tra le istanze. Un altro motivo potrebbe essere quello di poter aggiornare i contenuti di un sito web senza interruzioni. HAProxy può anche contribuire a mitigare gli attacchi DOS e DDOS.

Questa guida analizza l'uso di HAProxy con due istanze del sito web e il bilanciamento del carico con rotazione round-robin sullo stesso host LXD. Questa potrebbe essere una soluzione perfetta per garantire che gli aggiornamenti possano essere eseguiti senza tempi di inattività.

Tuttavia, se il problema sono le prestazioni del sito web, potrebbe essere necessario distribuire i siti multipli su host fisici o LXD multipli. È certamente possibile fare tutto questo su una macchina fisica senza usare LXD. Tuttavia, LXD offre grande flessibilità e prestazioni ed è eccellente per i test di laboratorio.

## Prerequisiti e presupposti

* Completo comfort alla riga di comando su una macchina Linux
* Esperienza con un editor a riga di comando (qui si usa `vim`)
* Esperienza con `crontab`
* Conoscenza di LXD. Per ulteriori informazioni, è possibile consultare il documento [LXD Server](../../books/lxd_server/00-toc.md). È possibile installare LXD su un notebook o una workstation senza eseguire l'installazione completa del server. Questo documento è stato scritto con una macchina da laboratorio che esegue LXD, ma non è impostato come un intero server, come invece avviene nel documento collegato in precedenza.
* Conoscenza dell'installazione, della configurazione e dell'utilizzo di server web.
* Si presuppone che LXD sia già installato e pronto a creare i contenitori.

## Installare i container

Sul vostro host LXD per questa guida, avrete bisogno di tre container. Volendo, si possono avere più contenitori di server web. Useremo **web1** e **web2** per i container del nostro sito web e **proxyha** per il nostro container di HAProxy. Per installarli sull'host LXD, procedere come segue:

```
lxc launch images:rockylinux/8 web1
lxc launch images:rockylinux/8 web2
lxc launch images:rockylinux/8 proxyha
```
L'esecuzione di un elenco `lxc` dovrebbe restituire qualcosa di simile:

```
+---------+---------+----------------------+------+-----------+-----------+
|  NAME   |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+---------+---------+----------------------+------+-----------+-----------+
| proxyha | RUNNING | 10.181.87.137 (eth0) |      | CONTAINER | 0         |
+---------+---------+----------------------+------+-----------+-----------+
| web1    | RUNNING | 10.181.87.207 (eth0) |      | CONTAINER | 0         |
+---------+---------+----------------------+------+-----------+-----------+
| web2    | RUNNING | 10.181.87.34 (eth0)  |      | CONTAINER | 0         |
+---------+---------+----------------------+------+-----------+-----------+
```

## Creazione e utilizzo del profilo `macvlan`

I container vengono eseguiti sull'interfaccia bridge predefinita con indirizzi DHCP assegnati dal bridge. Questi devono passare agli indirizzi DHCP della nostra LAN locale. La prima cosa da fare è creare e assegnare il profilo `macvlan`.

Iniziate con la creazione del profilo:

`lxc profile create macvlan`

Assicurarsi che l'editor sia impostato su quello preferito, in questo caso `vim`:

`export EDITOR=/usr/bin/vim`

Successivamente, modificate il profilo `macvlan`. Prima di farlo, è necessario conoscere l'interfaccia utilizzata dall'host per la nostra LAN. Eseguire `ip addr` e cercare l'interfaccia con l'assegnazione dell'IP LAN:

```
2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether a8:5e:45:52:f8:b6 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.141/24 brd 192.168.1.255 scope global dynamic noprefixroute eno1
```
!!! Note "Nota"

    In questo caso, l'interfaccia che si sta cercando è "eno1", che potrebbe essere completamente diversa sul vostro sistema. Utilizzate le **vostre** informazioni sull'interfaccia!

Ora che si conosce l'interfaccia LAN, è possibile modificare il profilo `macvlan`. A tal fine, alla riga di comando inserire:

`lxc profile edit macvlan`

Modificate il profilo in modo che assomigli a questo. L'autore ha escluso i commenti all'inizio del file, ma se siete nuovi di LXD, esaminateli:

```
config: {}
description: ""
devices:
  eth0:
    name: eth0
    nictype: macvlan
    parent: eno1
    type: nic
name: macvlan
```

Quando si crea il profilo `macvlan`, il sistema copia il profilo `default`. La modifica del profilo `default` è impossibile.

Ora che il profilo `macvlan` esiste, è necessario applicarlo ai nostri tre container:

```
lxc profile assign web1 default,macvlan
lxc profile assign web2 default,macvlan
lxc profile assign proxyha default,macvlan
```

Sfortunatamente, il comportamento predefinito di `macvlan`, come implementato nel kernel, è inspiegabilmente interrotto all'interno di un container LXD (vedere [questo documento](../../books/lxd_server/06-profiles.md)) `dhclient` all'avvio in ciascuno dei container.

Questa operazione è piuttosto semplice quando si usa il DHCP. Procedere in questo modo per ogni container:

* `lxc exec web1 bash`, che ci porterà alla riga di comando del contenitore **web1**
* `crontab -e` che modificherà il file di root `crontab` sul container
* digitare `i` per passare alla modalità di inserimento.
* aggiungere una riga: `@reboot /usr/sbin/dhclient`
* premere il tasto `ESC` per uscire dalla modalità di inserimento.
* salvare le modifiche con `SHIFT: wq`
* digitare `exit` per uscire dal container

Ripetere i passaggi per **web2** e **proxyha**.

Una volta completati questi passaggi, riavviare i container:

```
lxc restart web1
lxc restart web2
lxc restart proxyha
```

e quando si esegue nuovamente un `lxc list`, si vedrà che gli indirizzi DHCP sono ora assegnati dalla LAN:

```
+---------+---------+----------------------+------+-----------+-----------+
|  NAME   |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+---------+---------+----------------------+------+-----------+-----------+
| proxyha | RUNNING | 192.168.1.149 (eth0) |      | CONTAINER | 0         |
+---------+---------+----------------------+------+-----------+-----------+
| web1    | RUNNING | 192.168.1.150 (eth0) |      | CONTAINER | 0         |
+---------+---------+----------------------+------+-----------+-----------+
| web2    | RUNNING | 192.168.1.101 (eth0) |      | CONTAINER | 0         |
+---------+---------+----------------------+------+-----------+-----------+
```

## Installazione di Apache e modifica della schermata di benvenuto

Il nostro ambiente è pronto. Quindi, installare Apache (`httpd`) su ogni container web. È possibile farlo senza accedervi fisicamente:

```
lxc exec web1 dnf install httpd
lxc exec web2 dnf install httpd
```
Per qualsiasi server web moderno è necessario più di Apache, ma questo è sufficiente per eseguire alcuni test.

Quindi, abilitate `htpd`, avviatelo e modificate la schermata di benvenuto predefinita. In questo modo, si sa che il server risponde quando si prova ad accedere tramite proxy.

Attivare e avviare `htpd`:

```
lxc exec web1 systemctl enable httpd
lxc exec web1 systemctl start httpd
lxc exec web2 systemctl enable httpd
lxc exec web2 systemctl start httpd
```

Modificare la schermata di benvenuto. Questa schermata viene visualizzata quando non è configurato alcun sito web, in pratica è una pagina predefinita che viene caricata. In Rocky Linux, questa pagina si trova qui `/usr/share/httpd/noindex/index.html`. La modifica di questo file non richiede l'accesso diretto al container. È sufficiente procedere come segue:

`lxc exec web1 vi /usr/share/httpd/noindex/index.html`

cercare il tag `<h1>`, che mostrerà quanto segue:

`<h1>HTTP Server <strong>Test Page</strong></h1>`

Modificare la riga in modo da leggere:

`<h1>SITE1 HTTP Server <strong>Test Page</strong></h1>`

Ora ripetete la procedura per web2. Se si accede a questi computer tramite IP in un browser, ora viene visualizzata la pagina di benvenuto corretta per ciascuno di essi. C'è ancora molto da fare con i server web, ma per il momento lasciamo perdere e passiamo al server proxy.

## Installazione di HAProxy su proxyha e configurazione del proxy LXD

È semplice installare HAProxy sul contenitore proxy. Anche in questo caso, non è necessario accedere direttamente al contenitore:

`lxc exec proxyha dnf install haproxy`

Poi si vuole configurare `haproxy` per ascoltare sulla porta 80 e sulla porta 443 per i servizi web. Questo si fa con il sottocomando configure di `lxc`:
```
lxc config device add proxyha http proxy listen=tcp:0.0.0.0:80 connect=tcp:127.0.0.1:80
lxc config device add proxyha https proxy listen=tcp:0.0.0.0:443 connect=tcp:127.0.0.1:443
```

Per i nostri test, utilizzeremo solo la porta 80, o traffico HTTP, ma questo mostra come configurare il container per ascoltare le porte web predefinite per HTTP e HTTPS. L'uso di questo comando assicura anche che il riavvio del container **proxyha** mantenga le porte in ascolto.

## Configurazione di HAProxy

Si è già installato HAProxy sul container, ma non si è ancora fatto nulla per la configurazione. Prima di configurare, è necessario fare qualcosa per risolvere gli host. Normalmente si utilizzano nomi di dominio completamente qualificati, ma in questo ambiente di laboratorio si utilizzano gli IP. Per ottenere alcuni nomi associati alle macchine, si aggiungeranno alcuni record di file host al container **proxyha**.

`lxc exec proxyha vi /etc/hosts`

Aggiungere i seguenti record alla fine del file:

```
192.168.1.150   site1.testdomain.com     site1
192.168.1.101   site2.testdomain.com     site2
```

Il che consente al container **proxyha** di risolvere questi nomi.

Modificare il file `haproxy.cfg`. Non si utilizza molto del file originale. È necessario prima eseguire un backup del file spostandolo con un nome diverso:

`lxc exec proxyha mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.orig`

Creare un nuovo file di configurazione:

`lxc exec proxyha vi /etc/haproxy/haproxy.cfg`

Si noti che, per il momento, le linee del protocollo HTTPS sono state escluse. In un ambiente di produzione, è necessario utilizzare un certificato jolly che copra i server Web e che abiliti l'HTTPS:

```
global
log /dev/log local0
log /dev/log local1 notice
chroot /var/lib/haproxy
stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
stats timeout 30s
user haproxy
group haproxy
daemon

# For now, all https is remarked out
#
#ssl-default-bind-options no-sslv3 no-tlsv10 no-tlsv11 no-tls-tickets
#ssl-default-bind-ciphers EECDH+AESGCM:EDH+AESGCM
#tune.ssl.default-dh-param 2048

defaults
log global
mode http
option httplog
option dontlognull
option forwardfor
option http-server-close
timeout connect 5000
timeout client 50000
timeout server 50000
errorfile 400 /etc/haproxy/errors/400.http
errorfile 403 /etc/haproxy/errors/403.http
errorfile 408 /etc/haproxy/errors/408.http
errorfile 500 /etc/haproxy/errors/500.http
errorfile 502 /etc/haproxy/errors/502.http
errorfile 503 /etc/haproxy/errors/503.http
errorfile 504 /etc/haproxy/errors/504.http

# For now, all https is remarked out
# frontend www-https
# bind *:443 ssl crt /etc/letsencrypt/live/example.com/example.com.pem
# reqadd X-Forwarded-Proto:\ https

# acl host_web1 hdr(host) -i site1.testdomain.com
# acl host_web2 hdr(host) -i site2.testdomain.com

# use_backend subdomain1 if host_web1
# use_backend subdomain2 if host_web2

frontend http_frontend
bind *:80

acl web_host1 hdr(host) -i site1.testdomain.com
acl web_host2 hdr(host) -i site2.testdomain.com

use_backend subdomain1 if web_host1
use_backend subdomain2 if web_host2

backend subdomain1
# balance leastconn
  balance roundrobin
  http-request set-header X-Client-IP %[src]
# redirect scheme https if !{ ssl_fc }
     server site1 site1.testdomain.com:80 check
     server site2 web2.testdomain.com:80 check

backend subdomain2
# balance leastconn
  balance roundrobin
  http-request set-header X-Client-IP %[src]
# redirect scheme https if !{ ssl_fc }
     server site2 site2.testdomain.com:80 check
     server site1 site1.testdomain.com:80 check
```

Una breve spiegazione di ciò che sta accadendo sopra. Si dovrebbe vedere nei test, quando si arriva alla sezione dei test di questa guida (sotto):

Le definizioni di **site1** e **site2** si trovano nella sezione "acl". Ogni sito partecipa ai round-robin dell'altro per i rispettivi back-end. Quando si va su site1.testdomain.com nel test, l'URL non cambia, ma la pagina interna cambia ogni volta che si accede alla pagina da **site1** a **site2**. Lo stesso vale per site2.testdomain.com.

In questo modo si mostra che il cambio è in atto, ma in realtà il contenuto del sito web sarà esattamente lo stesso indipendentemente dal server che si sta utilizzando. Si noti che il documento mostra come si potrebbe distribuire il traffico tra più host. Si può anche usare "leastcon" nella linea di bilanciamento, e invece di cambiare in base al risultato precedente, verrà caricato il sito con il minor numero di connessioni.

### I file di errore

Alcune versioni di HAProxy sono dotate di un set standard di file di errore web, ma la versione fornita da Rocky Linux (e dal fornitore upstream) non ha questi file. Probabilmente **vorrete** crearli, perché potrebbero aiutarvi a risolvere eventuali problemi. Questi file vanno nella directory `/etc/haproxy/errors`, che non esiste.

Per prima cosa, creare la directory:

`lxc exec proxyha mkdir /etc/haproxy/errors`

Creare ciascuno di questi file in quella directory. Si noti che è possibile eseguire questa operazione con ogni nome di file dall'host LXD con il comando `lxc exec proxyha vi /etc/haproxy/errors/filename.http`, dove "filename.http" fa riferimento a uno dei nomi di file riportati di seguito. In un ambiente di produzione, le aziende potrebbero avere errori più specifici da poter utilizzare:

Nome file `400.http`:

```
HTTP/1.0 400 Bad request
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>400 Bad request</h1>
Your browser sent an invalid request.
</body></html>
```

Nome file `403.http`:

```
HTTP/1.0 403 Forbidden
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>403 Forbidden</h1>
Request forbidden by administrative rules.
</body></html>
```

Nome file `408.http`:

```
HTTP/1.0 408 Request Time-out
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>408 Request Time-out</h1>
Your browser didn't send a complete request in time.
</body></html>
```

Nome file `500.http`:

```
HTTP/1.0 500 Internal Server Error
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>500 Internal Server Error</h1>
An internal server error occurred.
</body></html>
```

Nome file `502.http`:

```
HTTP/1.0 502 Bad Gateway
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>502 Bad Gateway</h1>
The server returned an invalid or incomplete response.
</body></html>
```

Nome file `503.http`:

```
HTTP/1.0 503 Service Unavailable
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>503 Service Unavailable</h1>
No server is available to handle this request.
</body></html>
```

Nome file `504.http`:

```
HTTP/1.0 504 Gateway Time-out
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>504 Gateway Time-out</h1>
The server didn't respond in time.
</body></html>
```

## Esecuzione del proxy

Creare una cartella "run" per `haproxy` prima di avviare il servizio:

`lxc exec proxyha mkdir /run/haproxy`

Quindi, abilitare il servizio e avviarlo:
```
lxc exec proxyha systemctl enable haproxy
lxc exec proxyha systemctl start haproxy
```
Se si verificano errori, ricercare il motivo utilizzando:

`lxc exec proxyha systemctl status haproxy`

Se tutto si avvia e funziona senza problemi, siete pronti a passare alla fase di test.

## Verifica del proxy

Come per l'impostazione degli host (`/etc/hosts`), utilizzata affinché il nostro container **proxyha** possa risolvere i server web, e poiché il nostro ambiente di laboratorio non ha un server DNS locale in funzione, impostiamo i valori IP sulla nostra macchina locale per ogni sito web, in modo che corrispondano al nostro container haproxy.

Per farlo, modificare il file `/etc/hosts` sul computer locale. Considerate questo metodo di risoluzione dei domini come un "DNS dei poveri"

`sudo vi /etc/hosts`

Aggiungete queste due righe:

```
192.168.1.149   site1.testdomain.com     site1
192.168.1.149   site2.testdomain.com     site2
```

Se si esegue un ping su **site1** o **site2** sulla macchina locale, si otterrà una risposta da **proxyha**:

```
PING site1.testdomain.com (192.168.1.149) 56(84) bytes of data.
64 bytes from site1.testdomain.com (192.168.1.149): icmp_seq=1 ttl=64 time=0.427 ms
64 bytes from site1.testdomain.com (192.168.1.149): icmp_seq=2 ttl=64 time=0.430 ms
```

Aprite il browser Web e digitate site1.testdomain.com (o site2.testdomain.com) come URL nella barra degli indirizzi. Si otterrà una risposta da una delle due pagine di test e se si carica nuovamente la pagina, si otterrà la pagina di test del server successivo. Si noti che l'URL non cambia, ma la pagina restituita cambia alternativamente tra i server.


![screenshot of web1 being loaded and showing the second server test message](../images/haproxy_apache_lxd.png)

## Registrazione

Anche se il nostro file di configurazione è impostato correttamente per il logging, sono necessarie due cose: Primo, una cartella in /var/lib/haproxy/ chiamata "dev":

`lxc exec proxyha mkdir /var/lib/haproxy/dev`

Quindi, creare un processo di sistema per `rsyslogd` per catturare le istanze dal socket (`/var/lib/haproxy/dev/log` in questo caso) e memorizzarle in `/var/log/haproxy.log`:

`lxc exec proxyha vi /etc/rsyslog.d/99-haproxy.conf`

Aggiungete il seguente contenuto al file:

```
$AddUnixListenSocket /var/lib/haproxy/dev/log

# Send HAProxy messages to a dedicated logfile
:programname, startswith, "haproxy" {
  /var/log/haproxy.log
  stop
}
```
Salvare il file, uscire e riavviare `rsyslog`:

`lxc exec proxyha systemctl restart rsyslog`

Per riempire subito il file di log, riavviare di nuovo `haproxy`:

`lxc exec proxyha systemctl restart haproxy`

Visualizzare il file di registro creato:

`lxc exec proxyha more /var/log/haproxy.log`

Il che mostrerà qualcosa di simile a questo:

```
Sep 25 23:18:02 proxyha haproxy[4602]: Proxy http_frontend started.
Sep 25 23:18:02 proxyha haproxy[4602]: Proxy http_frontend started.
Sep 25 23:18:02 proxyha haproxy[4602]: Proxy subdomain1 started.
Sep 25 23:18:02 proxyha haproxy[4602]: Proxy subdomain1 started.
Sep 25 23:18:02 proxyha haproxy[4602]: Proxy subdomain2 started.
Sep 25 23:18:02 proxyha haproxy[4602]: Proxy subdomain2 started.
```

## Conclusioni

HAProxy è un potente motore proxy utilizzato per molte attività. È un bilanciatore di carico open source ad alte prestazioni e un reverse proxy per applicazioni TCP e HTTP. Questo documento ha dimostrato come utilizzare il bilanciamento del carico di due istanze del server Web.

È possibile utilizzarlo anche per altre applicazioni, compresi i database. Funziona all'interno di container LXD e su server indipendenti.

Ci sono molti usi non contemplati in questo documento. Consultate il [manuale ufficiale di HAProxy qui.](https://cbonte.github.io/haproxy-dconv/1.8/configuration.html)
