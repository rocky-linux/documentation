---
title: Rapporti dei Processi con Postfix
author: Steven Spencer
contributors: Ezequiel Bruni, Franco Colussi
tested_with: 8.5, 8.6, 9.0
tags:
  - email
  - reports
  - tools
---

# Utilizzo di Postfix per i Rapporti dei Processi del Server

## Prerequisiti

* Completo comfort nell'operare dalla riga di comando su un server Rocky Linux
* Familiarità con un editor di vostra scelta (questo documento utilizza l'editor _vi_, ma potete sostituirlo con il vostro editor preferito)
* Conoscenza del DNS (Domain Name System) e dei nomi host
* L'abilità di assegnare variabili in uno script bash
* Conoscere le funzioni dei comandi _tail_, _more_, _grep_ e _date_

## Introduzione

Molti amministratori di server Rocky Linux scrivono script per eseguire attività specifiche, come i backup o la sincronizzazione dei file, e molti di questi script generano log che contengono informazioni utili e talvolta molto importanti. Tuttavia, il solo fatto di avere i registri non è sufficiente. Se un processo fallisce e ne viene registrato il fallimento, ma l'amministratore impegnato non esamina il registro, potrebbe verificarsi una catastrofe.

Questo documento mostra come utilizzare l'MTA (mail transfer agent) di _postfix_ per prendere i dettagli del log da un particolare processo e inviarli all'utente via e-mail. Inoltre, tratta dei formati delle date nei registri e aiuta a identificare il formato da utilizzare nella procedura di creazione dei rapporti.

Tenete presente, però, che questa è solo la punta dell'iceberg di ciò che si può fare con la segnalazione tramite postfix. Si noti inoltre che è sempre una buona mossa di sicurezza limitare i processi in esecuzione solo a quelli di cui si ha sempre bisogno.

Questo documento mostra come attivare postfix solo per le attività di invio dei rapporti necessarie e poi spegnerlo di nuovo.

## Definizione Postfix

postfix è un demone server utilizzato per l'invio di e-mail. È più sicuro e più semplice di sendmail, un altro MTA che per anni è stato l'MTA predefinito. Può essere utilizzato come parte di un server di posta completo.

## Installazione di postfix

Oltre a postfix, avremo bisogno di _mailx_ per testare la nostra capacità di inviare e-mail. Per installare entrambi e le eventuali dipendenze necessarie, inserite quanto segue nella riga di comando del server Rocky Linux:

`dnf install postfix mailx`

!!! warning "Modifiche a Rocky Linux 9.0"

    Questa procedura funziona perfettamente in Rocky Linux 9.0. La differenza è data dalla provenienza del comando `mailx`. Mentre in 8.x è possibile installarlo per nome, in 9.0 `mailx` proviene dal pacchetto appstream `s-nail`. Per installare i pacchetti necessari, è necessario utilizzare:

    ```
    dnf install postfix s-nail
    ```

## Test e configurazione di Postfix

### Prima il test della Posta

Prima di configurare postfix, dobbiamo scoprire come appare la posta quando lascia il server, perché probabilmente vorremo cambiarla. Per farlo, avviare postfix:

`systemctl start postfix`

Quindi testatelo usando il comando mail che è installato con mailx:

`mail -s "Testing from server" myname@mydomain.com`

Verrà visualizzata una riga vuota. Digitate qui il vostro messaggio di prova:

`testing from the server`

Ora premete invio e inserite un singolo punto:

`.`

Il sistema risponde con:

`EOT`

Il nostro scopo è quello di verificare come appare la nostra posta all'esterno, cosa che possiamo capire dal maillog che si attiva all'avvio di postfix.

Utilizzare questo comando per visualizzare l'output del file di log:

`tail /var/log/maillog`

Si dovrebbe vedere qualcosa di simile, anche se il file di registro potrebbe avere domini diversi per l'indirizzo e-mail, ecc:

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
L'indirizzo "somehost.localdomain" indica che è necessario apportare alcune modifiche, per cui occorre prima arrestare il demone postfix:

`systemctl stop postfix`

## Configurazione di Postfix

Poiché non stiamo configurando un server di posta completo e perfettamente funzionante, le opzioni di configurazione che utilizzeremo non sono così ampie. La prima cosa da fare è modificare il file _main.cf_ (letteralmente il file di configurazione principale di postfix), quindi facciamo prima un backup:

`cp /etc/postfix/main.cf /etc/postfix/main.cf.bak`

Quindi modificarlo:

`vi /etc/postfix/main.cf`

Nel nostro esempio, il nome del server sarà "bruno" e il nome del dominio "ourdomain.com". Trovare la riga nel file:

`#myhostname = host.domain.tld`

È possibile rimuovere l'annotazione (#) o aggiungere una nuova riga sotto questa riga. In base al nostro esempio, la riga si legge:

`myhostname = bruno.ourdomain.com`

Quindi, trovare la riga per il nome di dominio:

`#mydomain = domain.tld`

Rimuovere l'annotazione e modificarla, oppure aggiungere una nuova riga:

`mydomain = ourdomain.com`

Infine, andate in fondo al file e aggiungete questa riga:

`smtp_generic_maps = hash:/etc/postfix/generic`

Salvate le modifiche (in vi, sarà `Shift : wq!`) e uscite dal file.

Prima di continuare a modificare il file generico, dobbiamo vedere come apparirà l'e-mail. In particolare, vogliamo creare il file "generic" a cui abbiamo fatto riferimento nel file _main.cf_ precedente:

`vi /etc/postfix/generic`

Questo file indica a postfix come devono apparire le e-mail provenienti da questo server. Ricordate la nostra e-mail di prova e il file di log? È qui che risolviamo tutto questo:

```
root@somehost.localdomain       root@bruno.ourdomain.com
@somehost.localdomain           root@bruno.ourdomain.com
```
Ora dobbiamo dire a postfix di utilizzare tutte le nostre modifiche. Questo viene fatto con il comando postmap:

`postmap /etc/postfix/generic`

Ora avviate postfix e testate di nuovo la vostra email usando la stessa procedura di cui sopra. Ora si dovrebbe vedere che tutte le istanze di "localdomain" sono state cambiate con il dominio effettivo.

### Il comando date e una variabile denominata Today

Non tutte le applicazioni utilizzano lo stesso formato di registrazione della data. Ciò significa che potrebbe essere necessario essere creativi con qualsiasi script scritto per la creazione di rapporti per data.

Supponiamo di voler esaminare il log di sistema, ad esempio, per estrarre tutto ciò che ha a che fare con dbus-daemon per la data odierna e inviarlo via e-mail a noi stessi. (Probabilmente non è l'esempio migliore, ma vi darà un'idea di come si fa)

Nel nostro script dobbiamo usare una variabile che chiameremo "today" e vogliamo che sia correlata all'output del comando "date" e che sia formattata in un modo specifico, in modo da poter ottenere i dati necessari dal nostro log di sistema (in _/var/log/messages_). Per cominciare, facciamo un po' di lavoro di indagine.

Per prima cosa, inserite il comando date nella riga di comando:

`date`

Questo dovrebbe fornire l'output predefinito della data di sistema, che potrebbe essere qualcosa di simile:

`Thu Mar  4 18:52:28 UTC 2021`

Ora controlliamo il registro di sistema e vediamo come registra le informazioni. Per farlo, utilizzeremo i comandi "more" e "grep":

`more /var/log/messages | grep dbus-daemon`

Il che dovrebbe dare un risultato simile a questo:

```
Mar  4 18:23:53 hedgehogct dbus-daemon[60]: [system] Successfully activated service 'org.freedesktop.nm_dispatcher'
Mar  4 18:50:41 hedgehogct dbus-daemon[60]: [system] Activating via systemd: service name='org.freedesktop.nm_dispatcher' unit='dbus-org.freedesktop.nm-dispatcher.service' requested by ':1.1' (uid=0 pid=61 comm="/usr/sbin/NetworkManager --no-daemon " label="unconfined")
Mar  4 18:50:41 hedgehogct dbus-daemon[60]: [system] Successfully activated service 'org.freedesktop.nm_dispatcher
```

La data e i log devono essere esattamente uguali nel nostro script, quindi vediamo come formattare la data usando una variabile chiamata "today".

Per prima cosa, vediamo cosa fare con la data per ottenere lo stesso risultato del log di sistema. È possibile fare riferimento alla [pagina man di Linux](https://man7.org/linux/man-pages/man1/date.1.html) o digitare `man date` sulla riga di comando per richiamare la pagina di manuale della data per ottenere le informazioni necessarie.

Per formattare la data nello stesso modo in cui lo fa _/var/log/messages_, è necessario usare le stringhe di formato %b e %e, dove %b è il mese di 3 caratteri e %e è il giorno riempito di spazi.

### Lo Script

Per il nostro script bash, possiamo vedere che useremo il comando date e una variabile chiamata "today". (Tenete presente che il termine "today" è arbitrario. Si potrebbe chiamare questa variabile "late_for_dinner" se si vuole!). In questo esempio chiameremo il nostro script test.sh e lo collocheremo in _/usr/local/sbin_:

`vi /usr/local/sbin/test.sh`

Cominciamo con, beh, l'inizio del nostro script. Si noti che, anche se il commento nel nostro file dice che stiamo inviando questi messaggi alla posta elettronica, per il momento li stiamo solo inviando a un log output standard, in modo da poterne verificare la correttezza.

Inoltre, nel nostro primo tentativo, stiamo acquisendo tutti i messaggi per la data corrente, non solo i messaggi di dbus-daemon. Ce ne occuperemo tra poco.

Un'altra cosa da tenere presente è che il comando grep restituisce il nome del file nell'output, cosa che non vogliamo in questo caso, quindi abbiamo aggiunto l'opzione "-h" a grep per rimuovere il prefisso del nome del file. Inoltre, una volta impostata la variabile "today", dobbiamo cercare l'intera variabile come stringa, quindi dobbiamo metterla tra virgolette:

```
#!/bin/bash

# set the date string to match /var/log/messages
today=`date +"%b %e"`

# grab the dbus-daemon messages and send them to email
grep -h "$today" /var/log/messages
```

Per ora è tutto, quindi salvate le modifiche e rendete lo script eseguibile:

`chmod +x /usr/local/sbin/test.sh`

E poi testiamolo:

`/usr/local/sbin/test.sh`

Se tutto funziona correttamente, si dovrebbe ottenere un lungo elenco di tutti i messaggi di oggi in /var/log/messages, compresi, ma non solo, i messaggi di dbus-daemon.  In caso affermativo, il passo successivo è quello di limitare i messaggi ai messaggi di dbus-daemon. Modifichiamo di nuovo il nostro script:

`vi /usr/local/sbin/test.sh`

```
#!/bin/bash

# set the date string to match /var/log/messages
today=`date +"%b %e"`

# grab the dbus-daemon messages and send them to email
grep -h "$today" /var/log/messages | grep dbus-daemon
```

Eseguendo nuovamente lo script, si dovrebbero ottenere solo i messaggi di dbus-daemon e solo quelli che si sono verificati oggi (quando si sta seguendo questa guida).

C'è però un ultimo passo da fare. Ricordate che è necessario inviare questo documento via e-mail all'amministratore per la revisione. Inoltre, poiché su questo server utilizziamo _postfix_ solo per i rapporti, non vogliamo lasciare il servizio in esecuzione, quindi lo avvieremo all'inizio dello script e lo fermeremo alla fine. Introdurremo qui il comando _sleep_ per fare una pausa di 20 secondi per assicurarci che l'e-mail sia stata inviata prima di spegnere nuovamente _postfix_.  Questa modifica finale aggiunge i problemi di arresto, avvio e riposo appena discussi e invia il contenuto all'e-mail dell'amministratore.

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

Eseguite nuovamente lo script e dovreste ricevere un'e-mail dal server con il messaggio dbus-daemon.

È ora possibile utilizzare [un crontab](../automation/cron_jobs_howto.md) per programmare l'esecuzione a un'ora specifica.

## Conclusioni

L'uso di postfix può aiutare a tenere traccia dei log dei processi che si desidera monitorare. È possibile utilizzarlo insieme allo scripting bash per avere una solida padronanza dei processi di sistema ed essere informati in caso di problemi.
