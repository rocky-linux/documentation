---
title: HAProxy-Apache-LXD
author: Steven Spencer, Franco Colussi
contributors: Ezequiel Bruni, Antoine Le Morvan, Franco Colussi
tested_with: 8.5, 8.6, 9.0
---

# HAProxy Bilanciamento del carico di Apache usando i container LXD

## Introduzione

HAProxy sta per "High Availability Proxy" Questo proxy può trovarsi davanti a qualsiasi applicazione TCP (come i server web), ma è spesso usato per agire come bilanciatore di carico tra più istanze di un sito web.

Le ragioni di questa scelta possono essere molteplici. Se avete un sito web che viene visitato in modo intenso, l'aggiunta di un'altra istanza dello stesso sito web e l'inserimento di HAProxy in entrambe le istanze vi consente di distribuire il traffico tra le istanze. Un altro motivo potrebbe essere quello di poter aggiornare i contenuti di un sito web senza interruzioni. HAProxy può anche contribuire a mitigare gli attacchi DOS e DDOS.

In questa guida si analizzerà l'uso di HAProxy con due istanze del sito web e il bilanciamento del carico con rotazione round robin, sullo stesso host LXD. Questa potrebbe essere una soluzione perfetta per garantire che gli aggiornamenti possano essere eseguiti senza tempi di inattività.

Se il problema sono le prestazioni del sito web, tuttavia, potrebbe essere necessario distribuire i siti multipli su bare metal o tra più host LXD. È certamente possibile fare tutto questo su bare metal senza usare LXD, ma LXD offre grande flessibilità e prestazioni, ed è ottimo da usare per i test di laboratorio.

## Prerequisiti e Presupposti

* Completo comfort alla riga di comando su una macchina Linux
* Esperienza con un editor a riga di comando (qui si usa `vim`)
* Esperienza con `crontab`
* Conoscenza di LXD. Per ulteriori informazioni, è possibile consultare il documento [LXD Server](../../books/lxd_server/00-toc.md). È perfettamente possibile installare LXD anche su un computer portatile o una workstation senza eseguire l'installazione completa del server. Questo documento è stato scritto con una macchina da laboratorio che esegue LXD, ma non è impostata come un server completo come il documento collegato sopra.
* Conoscenza dell'installazione, della configurazione e dell'utilizzo di server web.
* Si presuppone che LXD sia già installato e pronto a creare i contenitori.

## Installare i Container

Sul vostro host LXD per questa guida, avremo bisogno di tre contenitori. Ovviamente, si possono avere più contenitori di server web, se lo si desidera. Useremo **web1** e **web2** per i contenitori del nostro sito web e **proxyha** per il nostro contenitore di HAProxy. Per installarli sull'host LXD, procedere come segue:

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

## Creare e sare il profilo `macvlan`

I container sono attualmente in esecuzione sull'interfaccia bridge predefinita con indirizzi DHCP assegnati dal bridge. Vogliamo usare gli indirizzi DHCP della nostra LAN locale, quindi la prima cosa da fare è creare e assegnare il profilo `macvlan`.

Iniziate con la creazione del profilo:

`lxc profile create macvlan`

Assicuratevi che l'editor sia impostato sul vostro editor preferito, in questo caso `vim`:

`export EDITOR=/usr/bin/vim`

Successivamente è necessario modificare il profilo `macvlan`. Ma prima di farlo, dobbiamo sapere quale interfaccia l'host sta usando per la nostra LAN, quindi eseguite `ip addr` e cercate l'interfaccia con l'assegnazione dell'IP della LAN:

```
2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether a8:5e:45:52:f8:b6 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.141/24 brd 192.168.1.255 scope global dynamic noprefixroute eno1
```
!!! Note "Nota"

    In questo caso, l'interfaccia che stiamo cercando è "eno1", ma potrebbe essere completamente diversa sul vostro sistema. Utilizzate le **vostre** informazioni sull'interfaccia!

Ora che conosciamo l'interfaccia LAN, possiamo modificare il nostro profilo `macvlan`. A tal fine, alla riga di comando digitare:

`lxc profile edit macvlan`

Il profilo dovrebbe avere un aspetto simile a questo. Abbiamo escluso i commenti all'inizio del file, ma se non conoscete LXD, dategli un'occhiata:

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

Quando abbiamo creato il profilo `macvlan`, è stato copiato il profilo `default`. Il profilo di `default` non può esser modificato.

Ora che abbiamo il profilo `macvlan`, dobbiamo applicarlo ai nostri tre container:

```
lxc profile assign web1 default,macvlan
lxc profile assign web2 default,macvlan
lxc profile assign proxyha default,macvlan
```

Sfortunatamente, il comportamento predefinito di `macvlan`, come implementato nel kernel, è inspiegabilmente interrotto all'interno di un container LXD (vedere [questo documento](../../books/lxd_server/06-profiles.md)) `dhclient` all'avvio in ciascuno dei container.

L'operazione è piuttosto semplice quando si utilizza il DHCP. Procedere in questo modo per ogni container:

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

e quando si esegue di nuovo un `lxc list`, si dovrebbe vedere che gli indirizzi DHCP sono ora assegnati dalla LAN:

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

## Installare Apache e Modificare la Schermata di Benvenuto

Ora che il nostro ambiente è impostato, dobbiamo installare Apache (`httpd`) su ogni container web. Questo può essere fatto senza accedervi fisicamente:

```
lxc exec web1 dnf install httpd
lxc exec web2 dnf install httpd
```
Anche se è chiaro che per qualsiasi server web moderno è necessario molto di più di Apache, questo è sufficiente per eseguire alcuni test.

Successivamente, dobbiamo abilitare `httpd`, avviarlo e modificare la schermata di benvenuto predefinita, in modo da sapere quale server stiamo visitando quando tentiamo di accedere tramite proxy.

Attivare e avviare `htpd`:

```
lxc exec web1 systemctl enable httpd
lxc exec web1 systemctl start httpd
lxc exec web2 systemctl enable httpd
lxc exec web2 systemctl start httpd
```

Ora che abbiamo `htpd` abilitato e avviato, modifichiamo la schermata di benvenuto. Questa è la schermata che viene visualizzata quando non è configurato alcun sito web, essenzialmente una pagina predefinita che viene caricata. In Rocky Linux, questa pagina si trova qui `/usr/share/httpd/noindex/index.html`. Per modificare questo file, ancora una volta, non è necessario l'accesso diretto al container. È sufficiente procedere come segue:

`lxc exec web1 vi /usr/share/httpd/noindex/index.html`

e poi fare una ricerca per il tag `<h1>`, che dovrebbe mostrare questo:

`<h1>HTTP Server <strong>Test Page</strong></h1>`

È sufficiente modificare la riga in modo da leggere:

`<h1>SITE1 HTTP Server <strong>Test Page</strong></h1>`

Ora ripetete la procedura per web2. Se si accede a questi computer tramite IP in un browser, si ottiene la pagina di benvenuto corretta per ciascuno di essi. C'è altro da fare sui server web, ma lasciamo questi ultimi e passiamo al server proxy.

## Installare HAProxy su proxyha e Configurazione del Proxy di LXD

È altrettanto facile installare HAProxy sul contenitore proxy. Anche in questo caso, non è necessario accedere direttamente al contenitore:

`lxc exec proxyha dnf install haproxy`

La prossima cosa da fare è configurare `haproxy` per ascoltare la porta 80 e la porta 443 per i servizi web. Questo viene fatto con il sottocomando configure di `lxc`:
```
lxc config device add proxyha http proxy listen=tcp:0.0.0.0:80 connect=tcp:127.0.0.1:80
lxc config device add proxyha https proxy listen=tcp:0.0.0.0:443 connect=tcp:127.0.0.1:443
```

Per i nostri test, useremo solo la porta 80, o il traffico HTTP, ma questo mostra come configurare il container per ascoltare le porte web predefinite sia per HTTP che per HTTPS. L'uso di questo comando assicura anche che il riavvio del container **proxyha** mantenga le porte in ascolto.

## Configurazione di HAProxy

Abbiamo già installato HAProxy sul contenitore, ma non abbiamo fatto nulla con la configurazione. Prima di fare qualsiasi cosa, dobbiamo fare qualcosa per gestire i nostri host. Normalmente si utilizzerebbero nomi di dominio completamente qualificati, ma in questo ambiente di laboratorio si utilizzano solo gli IP. Per ottenere alcuni nomi associati alle macchine, aggiungeremo alcuni record di file host al container **proxyha**.

`lxc exec proxyha vi /etc/hosts`

Aggiungere i seguenti record alla fine del file:

```
192.168.1.150   site1.testdomain.com     site1
192.168.1.101   site2.testdomain.com     site2
```

Il che dovrebbe consentire al container **proxyha** di risolvere questi nomi.

Una volta completata questa operazione, modifichiamo il file `haproxy.cfg`. Il file originale contiene talmente tante cose che non utilizzeremo che ne faremo prima una copia di sicurezza spostandolo con un altro nome:

`lxc exec proxyha mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.orig`

Ora creiamo un nuovo file di configurazione:

`lxc exec proxyha vi /etc/haproxy/haproxy.cfg`

Si noti che per ora abbiamo commentato tutte le linee del protocollo HTTPS. In un ambiente di produzione, si dovrebbe utilizzare un certificato wildcard che copra i server web e abiliti l'HTTPS:

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

Una breve spiegazione di ciò che sta accadendo qui sopra. Si dovrebbe vedere nei test, quando si arriva alla sezione dei test di questa guida (sotto):

Sia **site1** che **site2** sono definiti nella sezione "acl". Quindi sia **site1** che **site2** sono inclusi nel "roundrobin" reciproco per i rispettivi back-end. Quando si va su site1.testdomain.com nel test, l'URL non cambia, ma la pagina interna cambia ogni volta che si accede alla pagina da **site1** a **site2**. Lo stesso vale per site2.testdomain.com.

Questo viene fatto per mostrare il cambio, ma in realtà il contenuto del vostro sito web sarà esattamente lo stesso indipendentemente dal server che state utilizzando. Tenete presente che stiamo mostrando come si potrebbe distribuire il traffico tra più host. Si può anche usare "leastcon" nella linea di bilanciamento, e invece di cambiare in base al risultato precedente, verrà caricato il sito con il minor numero di connessioni.

### I file di Errore

Alcune versioni di HAProxy sono dotate di un set standard di file di errore web, ma la versione fornita da Rocky Linux (e dal fornitore upstream) non ha questi file. Probabilmente **vorrete** crearli, perché potrebbero aiutarvi a risolvere eventuali problemi. Questi file vanno nella directory `/etc/haproxy/errors`, che non esiste.

La prima cosa da fare è creare la directory:

`lxc exec proxyha mkdir /etc/haproxy/errors`

Quindi è necessario creare ciascuno di questi file in quella directory. Si noti che è possibile eseguire questa operazione con ogni nome di file dall'host LXD con il comando `lxc exec proxyha vi /etc/haproxy/errors/filename.http`, dove "filename.http" fa riferimento a uno dei nomi di file riportati di seguito. In un ambiente di produzione, l'azienda potrebbe avere errori più specifici da utilizzare:

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

È necessario creare una cartella "run" per `haproxy` prima di avviare il servizio:

`lxc exec proxyha mkdir /run/haproxy`

Successivamente, è necessario abilitare il servizio e avviarlo:
```
lxc exec proxyha systemctl enable haproxy
lxc exec proxyha systemctl start haproxy
```
Se si verificano errori, ricercare il motivo utilizzando:

`lxc exec proxyha systemctl status haproxy`

Se tutto si avvia e funziona senza problemi, siamo pronti a passare al test.

## Verifica del proxy

Come per l'impostazione degli host (`/etc/hosts`) che abbiamo usato per far sì che il nostro contenitore **proxyha** possa risolvere i server web, e poiché nel nostro ambiente di laboratorio non abbiamo un server DNS locale in funzione, dobbiamo impostare i valori IP sulla nostra macchina locale per entrambi i siti web site1 e site2, in modo che corrispondano al nostro contenitore haproxy.

Per fare questo, dobbiamo modificare il nostro file `/etc/hosts` sulla nostra macchina locale. Considerate questo metodo di risoluzione dei domini come un "DNS dei poveri"

`sudo vi /etc/hosts`

Aggiungete quindi queste due righe:

```
192.168.1.149   site1.testdomain.com     site1
192.168.1.149   site2.testdomain.com     site2
```

Se ora si fa il ping da **site1** o da **site2** sulla tua macchina locale, si dovrebbe ottenere una risposta da **proxyha**:

```
PING site1.testdomain.com (192.168.1.149) 56(84) bytes of data.
64 bytes from site1.testdomain.com (192.168.1.149): icmp_seq=1 ttl=64 time=0.427 ms
64 bytes from site1.testdomain.com (192.168.1.149): icmp_seq=2 ttl=64 time=0.430 ms
```

Ora aprite il browser web e digitate site1.testdomain.com (o site2.testdomain.com) come URL nella barra degli indirizzi. Si dovrebbe ottenere una risposta da una delle due pagine di test e se si carica nuovamente la pagina, si dovrebbe ottenere la pagina di test del server successivo. Si noti che l'URL non cambia, ma la pagina restituita cambia alternativamente tra i server.


![screenshot of web1 being loaded and showing the second server test message](../images/haproxy_apache_lxd.png)

## Registrazione

Anche se il nostro file di configurazione è impostato correttamente per il registro, abbiamo bisogno di due cose: Primo, abbiamo bisogno di una cartella in /var/lib/haproxy/ chiamata "dev":

`lxc exec proxyha mkdir /var/lib/haproxy/dev`

Successivamente, occorre creare un processo di sistema per `rsyslogd`, in modo che prenda le istanze dal socket (`/var/lib/haproxy/dev/log` in questo caso) e le memorizzi in `/var/log/haproxy.log`:

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
Salvare il file e uscire, quindi riavviare `rsyslog`:

`lxc exec proxyha systemctl restart rsyslog`

E per riempire subito il file di log con qualcosa, riavviare di nuovo `haproxy`:

`lxc exec proxyha systemctl restart haproxy`

Per esaminare il file di registro creato:

`lxc exec proxyha more /var/log/haproxy.log`

Che dovrebbe mostrare qualcosa di simile a questo:

```
Sep 25 23:18:02 proxyha haproxy[4602]: Proxy http_frontend started.
Sep 25 23:18:02 proxyha haproxy[4602]: Proxy http_frontend started.
Sep 25 23:18:02 proxyha haproxy[4602]: Proxy subdomain1 started.
Sep 25 23:18:02 proxyha haproxy[4602]: Proxy subdomain1 started.
Sep 25 23:18:02 proxyha haproxy[4602]: Proxy subdomain2 started.
Sep 25 23:18:02 proxyha haproxy[4602]: Proxy subdomain2 started.
```

## Conclusioni

HAProxy è un potente motore proxy che può essere utilizzato per molti scopi. È un bilanciatore di carico e un reverse proxy ad alte prestazioni e open source per applicazioni TCP e HTTP. In questo documento abbiamo mostrato come utilizzare il bilanciamento del carico di due istanze del server web.

Può essere utilizzato anche per altre applicazioni, compresi i database. Funziona all'interno di container LXD, ma anche su server bare metal e standalone.

Ci sono molti usi non contemplati in questo documento. Consultate il [manuale ufficiale di HAProxy qui.](https://cbonte.github.io/haproxy-dconv/1.8/configuration.html)
