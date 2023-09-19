---
title: Rapporti dei Processi con Postfix
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - email
  - reports
  - tools
---

# Utilizzo di `postfix` per la segnalazione dei processi del server

## Prerequisiti

* Completo comfort nell'operare dalla riga di comando su un server Rocky Linux
* Familiarità con un editor di vostra scelta (questo documento utilizza l'editor _vi_, ma potete sostituirlo con il vostro editor preferito)
* Conoscenza del DNS (Domain Name System) e dei nomi host
* L'abilità di assegnare variabili in uno script bash
* Conoscenza di ciò che fanno i comandi `tail`, `more`, `grep`, e `date`

## Introduzione

Molti amministratori di server Rocky Linux scrivono script per eseguire attività specifiche, come i backup o la sincronizzazione dei file, e molti di questi script generano log che contengono informazioni utili e talvolta molto importanti. Tuttavia, il solo fatto di avere i registri non è sufficiente. Se un processo fallisce e ne viene registrato il fallimento, ma l'amministratore impegnato non esamina il registro, potrebbe verificarsi una catastrofe.

Questo documento mostra come utilizzare l'MTA (mail transfer agent) di `postfix` per acquisire i dettagli del log da un particolare processo e inviarli via e-mail. Inoltre, tratta dei formati delle date nei registri e aiuta a identificare il formato da utilizzare nella procedura di creazione dei rapporti.

Ricordate che questa è solo la punta dell'iceberg di ciò che potete fare con la segnalazione tramite `postfix`. Da notare che è sempre una buona strategia di sicurezza limitare i processi in esecuzione solo a quelli di cui si ha bisogno per tutto il tempo.

Questo documento mostra come attivare postfix solo per le attività di invio dei rapporti necessarie e poi spegnerlo di nuovo.

## Definizione `postfix`

`postfix` è un demone server utilizzato per l'invio di e-mail. È più sicuro e più semplice di sendmail, un altro MTA che per anni è stato l'MTA predefinito. È possibile utilizzarlo come parte di un server di posta completo.

## Installazione di `postfix`

Oltre a `postfix`, è necessario `mailx` per verificare la capacità di inviare e-mail. Per installare queste e le eventuali dipendenze necessarie, inserire quanto segue nella riga di comando del server Rocky Linux:

`dnf install postfix mailx`

!!! warning "Modifiche a Rocky Linux 9.0"

    Questa procedura funziona perfettamente in Rocky Linux 9.0. La differenza è data dalla provenienza del comando `mailx`. Mentre in 8.x è possibile installarlo per nome, in 9.0 `mailx` proviene dal pacchetto appstream `s-nail`. Per installare i pacchetti necessari, è necessario utilizzare:

    ```
    dnf install postfix s-nail
    ```

## Test e configurazione di `postfix`

### Prima il test della Posta

Prima di configurare `postfix`, è necessario conoscere l'aspetto della posta quando lascia il server, poiché probabilmente si desidera modificarlo. Per farlo, avviare `postfix`:

`systemctl start postfix`

Eseguire il test con `mail` fornito da `mailx` (o `s-nail`):

`mail -s "Testing from server" myname@mydomain.com`

Verrà visualizzata una riga vuota. Digitare qui il messaggio di prova:

`testing from the server`

Premete invio e inserite un singolo punto:

`.`

Il sistema risponde con il seguente messaggio:

`EOT`

Lo scopo di questa operazione è di vedere come la nostra posta appare al mondo esterno. Si può avere un'idea di questo dal _maillog_ che si attiva all'avvio di `postfix`.

Utilizzare questo comando per visualizzare l'output del file di log:

`tail /var/log/maillog`

Si vedrà qualcosa di simile a questo, anche se il file di registro avrà domini diversi per l'indirizzo e-mail e altri elementi:

```
Mar  4 16:51:40 hedgehogct postfix/postfix-script[735]: starting the Postfix mail system
Mar  4 16:51:40 hedgehogct postfix/master[737]: daemon started -- version 3.3.1, configuration /etc/postfix
Mar  4 16:52:04 hedgehogct postfix/pickup[738]: C9D42EC0ADD: uid=0 from=<root>
Mar  4 16:52:04 hedgehogct postfix/cleanup[743]: C9D42EC0ADD: message-id=<20210304165204.C9D42EC0ADD@somehost.localdomain>
Mar  4 16:52:04 hedgehogct postfix/qmgr[739]: C9D42EC0ADD: from=<root@somehost.localdomain>, size=457, nrcpt=1 (queue active)
Mar  4 16:52:05 hedgehogct postfix/smtp[745]: connect to gmail-smtp-in.l.google.com[2607:f8b0:4001:c03::1a]:25: Network is unreachable
Mar  4 16:52:06 hedgehogct postfix/smtp[745]: C9D42EC0ADD: to=<myname@mydomain.com>, relay=gmail-smtp-in.l.google.com[172.217.212.26]
:25, delay=1.4, delays=0.02/0.02/0.99/0.32, dsn=2.0.0, status=sent (250 2.0.0 OK  1614876726 z8si17418573ilq.142 - gsmtp)
Mar  4 16:52:06 hedgehogct postfix/qmgr[739]: C9D42EC0ADD: removed
```
L'indirizzo "somehost.localdomain" indica che è necessario apportare alcune modifiche. Arrestare prima il demone `postfix`:

`systemctl stop postfix`

## Configurazione di `postfix`

Poiché non si sta configurando un server di posta completo e perfettamente funzionante, le opzioni di configurazione da utilizzare non sono numerose. La prima cosa da fare è modificare il file _main.cf_ (letteralmente il file di configurazione principale di `postfix`). Eseguire prima una copia di backup:

`cp /etc/postfix/main.cf /etc/postfix/main.cf.bak`

Modificarlo:

`vi /etc/postfix/main.cf`

Nel nostro esempio, il nome del server è "bruno" e il nome del dominio è "nostrodominio.com". Trovare la riga nel file:

`#myhostname = host.domain.tld`

È possibile rimuovere l'annotazione (#) o aggiungere una riga sotto questa riga. In base al nostro esempio, la riga si leggerà:

`myhostname = bruno.ourdomain.com`

Quindi, trovare la riga per il nome di dominio:

`#mydomain = domain.tld`

Anche in questo caso, rimuovete il commento e modificatelo, oppure aggiungete una riga sotto di esso:

`mydomain = ourdomain.com`

Infine, andate in fondo al file e aggiungete questa riga:

`smtp_generic_maps = hash:/etc/postfix/generic`

Salvare le modifiche (in `vi`, sarà `Shift : wq!`) e uscire dal file.

Prima di continuare a modificare il file generico, è necessario vedere come si presenterà l'e-mail. In particolare, si vuole creare il file " generic " a cui si fa riferimento nel file _main.cf_ di cui sopra:

`vi /etc/postfix/generic`

Questo file comunica a `postfix` l'aspetto di qualsiasi e-mail proveniente da questo server. Ricordate la nostra e-mail di prova e il file di log? È qui che risolviamo tutto questo:

```
root@somehost.localdomain       root@bruno.ourdomain.com
@somehost.localdomain           root@bruno.ourdomain.com
```
Successivamente, occorre indicare a `postfix` di utilizzare tutte le nostre modifiche. Questo si può fare con il comando postmap:

`postmap /etc/postfix/generic`

Avviate `postfix` e testate di nuovo la vostra email con la stessa procedura usata sopra. Ora si vedrà che tutte le istanze di "localdomain" sono ora il dominio effettivo.

### Il comando date e una variabile denominata Today

Non tutte le applicazioni utilizzano lo stesso formato di registrazione della data. Potrebbe essere necessario essere creativi con qualsiasi script si scriva per il reporting in base alla data.

Supponiamo di voler esaminare il registro di sistema come esempio e di voler estrarre tutto ciò che ha a che fare con dbus-daemon per la data odierna e di inviarlo via e-mail a noi stessi. (Probabilmente non è l'esempio migliore, ma vi darà un'idea di come potreste farlo)

È necessario utilizzare una variabile nello script. Chiamiamolo "today". Si vuole che si riferisca all'output del comando "date" e che lo formatti in un modo specifico, in modo da poter ottenere i dati necessari dal log del sistema. (in _/var/log/messages_). Per cominciare, fate alcune indagini.

Per prima cosa, inserite il comando date nella riga di comando:

`date`

In questo modo si otterrà l'output predefinito della data di sistema, che potrebbe essere simile a questa:

`Thu Mar  4 18:52:28 UTC 2021`

Controllate il registro di sistema e verificate come registra le informazioni. A tale scopo, utilizzare i comandi `more` e `grep`:

`more /var/log/messages | grep dbus-daemon`

Il risultato è qualcosa di simile a questo:

```
Mar  4 18:23:53 hedgehogct dbus-daemon[60]: [system] Successfully activated service 'org.freedesktop.nm_dispatcher'
Mar  4 18:50:41 hedgehogct dbus-daemon[60]: [system] Activating via systemd: service name='org.freedesktop.nm_dispatcher' unit='dbus-org.freedesktop.nm-dispatcher.service' requested by ':1.1' (uid=0 pid=61 comm="/usr/sbin/NetworkManager --no-daemon " label="unconfined")
Mar  4 18:50:41 hedgehogct dbus-daemon[60]: [system] Successfully activated service 'org.freedesktop.nm_dispatcher
```

La data e gli output del registro devono essere esattamente gli stessi nel nostro script. Vediamo come formattare la data con una variabile chiamata " today ".

Analizzate cosa dovete fare con la data per ottenere lo stesso risultato del log di sistema. È possibile fare riferimento alla [pagina man di Linux](https://man7.org/linux/man-pages/man1/date.1.html) o digitare `man date` sulla riga di comando per richiamare la pagina di manuale della data per ottenere le informazioni necessarie.

Per formattare la data allo stesso modo di _/var/log/messages_, è necessario usare le stringhe di formato %b e %e, con %b che è il mese di 3 caratteri e %e che è il giorno riempito con spazi.

### Lo script

Per il nostro script bash, possiamo dedurre che utilizzeremo il comando `date` e una variabile chiamata "today". (Tenete presente che il termine "today" è arbitrario. Questa variabile può essere chiamata in qualsiasi modo). In questo esempio, lo script verrà chiamato `test.sh` e collocato in _/usr/local/sbin_:

`vi /usr/local/sbin/test.sh`

All'inizio, si noti che anche se il commento nel nostro file dice che si stanno inviando questi messaggi alla posta elettronica, per ora li si sta solo inviando a un log output standard per verificare che siano corretti.

Inoltre, nella prima esecuzione dello script, vengono acquisiti tutti i messaggi per la data corrente, non solo i messaggi di dbus-daemon. Ce ne occuperemo a breve.

Tenete presente che il comando `grep` restituisce il nome del file in uscita, cosa che in questo caso non è desiderata. Per rimuoverlo, aggiungete l'opzione "-h" a grep. Inoltre, quando si imposta la variabile " today", è necessario cercare l'intera variabile come stringa, il che richiede la stringa all'interno delle virgolette:

```
#!/bin/bash

# set the date string to match /var/log/messages
today=`date +"%b %e"`

# grab the dbus-daemon messages and send them to email
grep -h "$today" /var/log/messages
```

Per il momento è tutto. Salvate le modifiche e rendete lo script eseguibile:

`chmod +x /usr/local/sbin/test.sh`

Testatelo:

`/usr/local/sbin/test.sh`

Se tutto funziona correttamente, si otterrà un lungo elenco di tutti i messaggi presenti in _/var/log/messages_ di oggi, compresi, ma non solo, i messaggi di dbus-daemon. Il passo successivo consiste nel limitare i messaggi ai messaggi di dbus-daemon. Modificare nuovamente lo script:

`vi /usr/local/sbin/test.sh`

```
#!/bin/bash

# set the date string to match /var/log/messages
today=`date +"%b %e"`

# grab the dbus-daemon messages and send them to email
grep -h "$today" /var/log/messages | grep dbus-daemon
```

Eseguendo nuovamente lo script, si otterranno solo i messaggi di dbus-daemon e solo quelli che si sono verificati oggi.

Rimane un ultimo passo da compiere. Ricordate che dovete inviare questo documento via e-mail all'amministratore per la revisione. Poiché si utilizza `postfix` su questo server solo per la reportistica, non si vuole lasciare il servizio in esecuzione. Avviatelo all'inizio dello script e fermatelo alla fine. In questo caso, il comando `sleep` fa una pausa di 20 secondi, assicurando l'invio dell'e-mail prima di chiudere nuovamente `postfix`. Questa modifica finale aggiunge i passaggi stop, start e sleep appena discussi e invia il contenuto all'e-mail dell'amministratore.

`vi /usr/local/sbin/test.sh`

E modificare lo script:

```
#!/bin/bash

# start postfix
/usr/bin/systemctl start postfix

# set the date string to match /var/log/messages
today=`date +"%b %e"`

# grab the dbus-daemon messages and send them to email
grep -h "$today" /var/log/messages | grep dbus-daemon | mail -s "dbus-daemon messages for today" myname@mydomain.com

# make sure the email has finished before continuing
sleep 20

# stop postfix
/usr/bin/systemctl stop postfix
```

Eseguite di nuovo lo script e avrete un'e-mail dal server con i messaggi di dbus-daemon.

È ora possibile utilizzare [un crontab](../automation/cron_jobs_howto.md) per programmare l'esecuzione a un'ora specifica.

## Conclusioni

Utilizzando `postfix` si può tenere traccia dei log dei processi che si desidera monitorare. È possibile utilizzarlo insieme allo scripting bash per avere una solida padronanza dei processi di sistema ed essere informati in caso di problemi.
