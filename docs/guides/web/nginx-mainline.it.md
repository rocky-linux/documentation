---
title: Nginx
author: Ezequiel Bruni
contributors: Antoine Le Morvan, Steven Spencer, Ganna Zhyrnova
tested_with: 8.5
tags:
  - nginx
  - web
---

# Come installare il più recente Nginx su Rocky Linux

## Introduzione

*Nginx* è un server web progettato per essere veloce, efficiente e compatibile con quasi tutto. Lo uso spesso e, una volta che ci si è abituati — è piuttosto facile da configurare e impostare. Ecco un breve riassunto delle caratteristiche principali; Nginx è/ha/può essere:

Ecco una breve panoramica dei modi in cui Nginx si distingue e delle sue caratteristiche:

* Un server web di base
* Un reverse proxy per dirigere il traffico verso più siti
* Un bilanciatore di carico integrato per gestire il traffico verso più siti web
* Caching dei file incorporato per la velocità
* WebSockets
* Supporto FastCGI
* E, naturalmente, IPv6

È fantastico! Quindi basta `sudo dnf install nginx`, giusto? Sì, è più o meno così, ma abbiamo incluso alcuni consigli utili per iniziare.

## Prerequisiti e Presupposti

Avrete bisogno di:

* Una macchina o un server Rocky Linux connesso a internet.
* Una familiarità di base con la riga di comando.
* La capacità di eseguire comandi come root, sia come utente root che con `sudo`.
* Un editor di testo a tua scelta, sia grafico che a riga di comando. Per questo tutorial, sto usando `nano`.

## Installare ed eseguire Nginx

Innanzitutto, assicuratevi che il vostro computer sia aggiornato:

```bash
sudo dnf update
```

Quindi, installare il pacchetto `nginx`:

```bash
sudo dnf install nginx
```

Una volta terminata l'installazione, avviare il servizio `nginx` e abilitarlo all'avvio automatico al riavvio:

```bash
sudo systemctl enable --now nginx
```

Per verificare che sia stata installata l'ultima versione di *Nginx* (la più recente dai repository Rocky, comunque), eseguire:

```bash
nginx -v
```

Da qui, si può iniziare a inserire i file HTML nella directory `/usr/share/nginx/html/` per costruire un semplice sito web statico. Il file di configurazione per il sito web/virtual host predefinito si chiama "nginx.conf" e si trova in `/etc/nginx/`. Contiene anche una serie di altre configurazioni di base del server Nginx, quindi anche se si sceglie di spostare la configurazione del sito web in un altro file, probabilmente si dovrebbe lasciare intatto il resto di "nginx.conf".

!!! Note

    Le versioni precedenti di questa guida descrivevano l'installazione di nginx-mainline. Questa non è più un'opzione. Nella maggior parte dei casi, la versione di Nginx presente nei repo di Rocky è più che sufficiente, in quanto fornisce una base stabile con patch di sicurezza retroportate. Chi vuole ancora utilizzare nginx-mainline può trovare metodi per farlo cercando sul web. Tutti i documenti di istruzioni trovati, tuttavia, si riferiscono a Rocky Linux 8. Si noti che l'uso di nginx-mainline è di solito perfettamente fattibile, ma non è supportato.

## Configurare il Firewall

!!! Note

    Se si sta installando Nginx su un contenitore come LXD/LXC o Docker, si può saltare questa parte per ora. Il firewall deve essere gestito dal sistema operativo host.

Probabilmente non otterrete nulla se cercate di visualizzare una pagina web con l'indirizzo IP o il nome di dominio del vostro computer da un altro computer. Questo sarà il caso se avete un firewall attivo e funzionante.

Per aprire le porte necessarie a "vedere" le pagine web, utilizzeremo il firewall integrato di Rocky Linux, `firewalld`. Il comando `firewalld` per farlo è `firewall-cmd`. Ci sono due modi per farlo: quello ufficiale e quello manuale. *In questo caso, la via ufficiale è la migliore,* ma è bene conoscerle entrambe per poterle utilizzare in futuro.

Il metodo ufficiale apre il firewall al servizio `http`, che è, ovviamente, il servizio che gestisce le pagine web. Eseguite questo:

```bash
sudo firewall-cmd --permanent --zone=public --add-service=http
```

Vediamo di analizzare la situazione:

* L'opzione `--permanent` indica al firewall di assicurarsi che questa configurazione sia utilizzata ogni volta che il firewall viene riavviato e quando il server viene riavviato.
* `--zone=public` dice al firewall di accettare connessioni in entrata a questa porta da chiunque.
* Infine, `--add-service=http` dice a `firewalld` di lasciar passare tutto il traffico HTTP verso il server.

Now here's the manual way to do it. È praticamente la stessa cosa, tranne per il fatto che si apre specificamente la porta 80 utilizzata da HTTP.

```bash
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
```

* `--add-port=80/tcp` dice al firewall di accettare le connessioni in entrata sulla porta 80, purché stiano usando il Transmission Control Protocol, che è quello che vuoi in questo caso.

Per il traffico SSL/HTTPS, è sufficiente eseguire nuovamente il comando e modificare il servizio o il numero di porta.

```bash
sudo firewall-cmd --permanent --zone=public --add-service=https
# Or, in some other cases:
sudo firewall-cmd --permanent --zone=public --add-port=443/tcp
```

Queste configurazioni non avranno effetto finché non si forza l'applicazione. Per fare ciò, dire a `firewalld` di rilasciare le sue configurazioni, in questo modo:

```bash
sudo firewall-cmd --reload
```

!!! Note

    Ora, c'è una piccolissima possibilità che questo non funzioni. In quei rari casi, fate in modo che `firewalld` esegua i vostri comandi con il vecchio metodo “spegnere e riaccendere”.

    ```bash
    systemctl restart firewalld
    ```

Per verificare che le porte siano state aggiunte correttamente, eseguire `firewall-cmd --list-all`. Un firewall correttamente configurato avrà un aspetto simile a questo:

```bash
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp9s0
  sources:
  services: cockpit dhcpv6-client ssh http https
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

E questo dovrebbe essere tutto ciò di cui avete bisogno, a livello di firewall.

*A questo punto* dovrebbe apparire una pagina web con un aspetto simile a questo:

![The Nginx welcome page](nginx/images/welcome-nginx.png)

It’s not much at all, but it means the server is working. È anche possibile verificare che la pagina web funzioni dalla riga di comando con:

```bash
curl -I http://[your-ip-address]
```

## Creazione di un utente del server e modifica della cartella principale del sito web

Sebbene *sia possibile* inserire il proprio sito web nella directory predefinita e partire (e questo potrebbe andare bene per *Nginx* quando è in esecuzione all'interno di un container o su un server di test/sviluppo), non è ciò che chiamiamo best practice. È invece una buona idea creare sul sistema un utente Linux specifico per il sito web e inserire i file del sito in una directory creata appositamente per quell'utente.

Se si desidera creare più siti web, è necessario creare diversi utenti e directory principali per garantire l'organizzazione e la sicurezza.

In questa guida avrò un solo utente: un bel diavolo di nome “www”. Decidere dove mettere i file del sito web diventa più complicato.

I file del sito web possono essere collocati in diversi punti, a seconda della configurazione del server. Se siete su un server bare-metal (fisico) o state installando `nginx` direttamente su un VPS, probabilmente avete in esecuzione Security Enhanced Linux (SELinux). SELinux è uno strumento che fa molto per proteggere la vostra macchina, ma che in un certo senso impone anche dove potete mettere certe cose, come le pagine web.

Quindi, se state installando `nginx` direttamente sulla vostra macchina, vorrete mettere i vostri siti web nelle sottodirectory della cartella principale predefinita. In questo caso, la radice predefinita è `/usr/share/nginx/html`, quindi il sito web per l'utente "www" potrebbe andare in `/usr/share/nginx/html/www`.

Se si esegue `nginx` in un contenitore come LXD/LXC, tuttavia, SELinux probabilmente *non sarà* installato e si potranno mettere i file dove si vuole. In questo caso, mi piace mettere tutti i file del sito web di un utente sotto una directory in una normale cartella home, in questo modo: `/home/www/`.

Tuttavia, continuerò questa guida come se SELinux fosse installato. Modificate solo ciò che è necessario in base al vostro caso d'uso. Per saperne di più sul funzionamento di SELinux, consultate la [nostra guida sull'argomento](../security/learning_selinux.md).

### Creazione dell'Utente

Per prima cosa, creiamo la cartella che utilizzeremo:

```bash
sudo mkdir /usr/share/nginx/html/www
```

Quindi, creare il gruppo www:

```bash
sudo groupadd www
```

Quindi, creiamo l'utente:

```bash
sudo adduser -G nginx -g www -d /usr/share/nginx/html/www www --system --shell=/bin/false
```

Questo comando indica alla macchina di:

* Creare un utente chiamato "www" (come da testo centrale),
* mettere tutti i suoi file in `/usr/share/nginx/html/www`,
* e aggiungerlo ai seguenti gruppi: "nginx" come supplementare, "www" come primario.
* Il flag `--system` dice che l'utente non è un utente umano, è riservato al sistema. Se volete creare account utente umani per gestire diversi siti web, questa è tutta un'altra guida.
* `--shell=/bin/false` si assicura che nessuno possa anche solo *tentare* di accedere come utente "www".

Il gruppo "nginx" fa una vera magia. Permette al server web di leggere e modificare i file che appartengono all'utente "www" e al gruppo utente "www". Per ulteriori informazioni, consultare la [guida sulla gestione degli utenti](../../books/admin_guide/06-users.md).

### Cambiare la Cartella Radice del Server

Ora che avete il vostro nuovo account utente, è il momento di far sì che `nginx` cerchi i file del vostro sito web in quella cartella. Prendete di nuovo il vostro editor di testo preferito.

Per ora, basta eseguire:

```bash
sudo nano /etc/nginx/conf.d/default.conf
```

Quando il file è aperto, cercate la riga che assomiglia a `root /usr/share/nginx/html;`. Cambiatela con la cartella principale del vostro sito web, ad esempio. `root /usr/share/nginx/html/www;` (o `/home/www` se si esegue `nginx` in container come faccio io). Salvare e chiudere il file, quindi verificare la configurazione di `nginx` per assicurarsi di non aver saltato un punto e virgola o altro:

```bash
nginx -t
```

Se viene visualizzato il seguente messaggio di successo, tutto è andato per il verso giusto:

```bash
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

Quindi, riavviare il server in modo soft con:

```bash
sudo systemctl reload nginx
```

!!! Note

    Nel caso improbabile in cui il riavvio soft non funzioni, date una spinta a `nginx` con:

    ```bash
    sudo systemctl restart nginx
    ```

Tutti i file HTML presenti nella nuova cartella principale dovrebbero ora essere navigabili da... il browser.

### Cambiare i Permessi ai File

I permessi devono essere impostati correttamente per garantire che `nginx` possa leggere, scrivere ed eseguire qualsiasi file nella directory del sito web.

Innanzitutto, assicurarsi che tutti i file della cartella principale siano di proprietà dell'utente del server e del suo gruppo di utenti:

```bash
sudo chown -R www:www /usr/share/nginx/html/www
```

Quindi, per garantire che gli utenti che desiderano navigare nel vostro sito web possano effettivamente vedere le pagine, eseguite questi comandi (e sì, quei punti e virgola sono importanti):

```bash
sudo find /usr/share/nginx/html/www -type d -exec chmod 555 "{}" \;
sudo find /usr/share/nginx/html/www -type f -exec chmod 444 "{}" \;
```

That basically gives everyone the right to look at files on the server, but not modify them. Solo gli utenti root e del server possono farlo.

## Ottenere certificati SSL per il vostro sito

La nostra [guida per ottenere certificati SSL con certbot](../security/generating_ssl_keys_lets_encrypt.md) è stata aggiornata con alcune istruzioni di base per `nginx`. Date un'occhiata a questo documento, che contiene istruzioni complete per l'installazione di certbot e per la generazione dei certificati.

Sta per arrivare il momento in cui i browser potrebbero smettere di far vedere i siti senza certificati, quindi assicuratevi di ottenerne uno per ogni sito.

## Opzioni di configurazione e guide aggiuntive

* Se vuoi vedere come far funzionare *Nginx* con PHP, e PHP-FPM in particolare, controlla la nostra [guida PHP su Rocky Linux](../web/php.md).
* Se vuoi imparare a configurare *Nginx* per più siti Web, ora abbiamo [una guida su questo argomento](nginx-multisite.md).

## Regole SELinux

Attenzione: se applicate, le direttive nginx proxy_pass falliranno con "502 Bad Gateway"

È possibile disabilitare setenforce per scopi di sviluppo

```bash
sudo setenforce 0
```

oppure si può abilitare `httpd` o altri servizi relativi a nginx in `/var/log/audit/audit.log`

```bash
sudo setsebool httpd_can_network_connect 1 -P
```

## Conclusione

L'installazione e la configurazione di base di `nginx` sono semplici, anche se è più complicato di quanto dovrebbe essere ottenere l'ultima versione. Ma seguite i passaggi e avrete una delle migliori opzioni di server in funzione rapidamente.

Ora dovete solo andare a costruirvi un sito web? Quanto ci vorrà, altri dieci minuti? *Sussurri silenziosi in Web Designer*
