---
title: SSH Chiave Pubblica e Privata
author: Steven Spencer, Franco Colussi
contributors: Ezequiel Bruni, Franco Colussi
tested_with: 8.5
tags:
  - security
  - ssh
  - keygen
---

# SSH Chiave Pubblica e Privata

## Prerequisiti

* Una certa comodità nell'operare dalla riga di comando
* Server Rocky Linux e/o workstations con *openssh* installati
    * Va bene, tecnicamente; questo processo funziona su qualsiasi sistema Linux con openssh installato
* Facoltativo: familiarità con i permessi di file Linux e directory

## Introduzione

SSH è un protocollo utilizzato per accedere da una macchina ad un'altra, di solito tramite la riga di comando. Con SSH è possibile eseguire comandi su computer e server remoti, inviare file e in genere gestire tutto ciò che si fa da un unico posto.

Quando si lavora con più server Rocky Linux in più posizioni, o se stai semplicemente cercando di risparmiare un po' di tempo per accedere a questi server, vorrai usare una coppia di chiavi private e pubbliche SSH. Le coppie di chiavi rendono sostanzialmente più facile accedere a macchine remote e eseguire i comandi.

Questo documento vi guiderà attraverso il processo di creazione delle chiavi e nella configurazione dei server per un accesso facilitato, con tali chiavi.

## Processo Per Generare Le Chiavi

I seguenti comandi sono tutti eseguiti dalla riga di comando sulla tua workstation Rocky Linux:

```
ssh-keygen -t rsa
```

Che mostrerà quanto segue:

```
Generazione della coppia di chiavi pubbliche/private rsa.
Enter file in which to save the key (/root/.ssh/id_rsa):
```

Premi Invio per accettare la posizione predefinita. Successivamente il sistema mostrerà:

`Enter passphrase (empty for no passphrase):`

Quindi clicca Invio qui. Infine, vi chiederà di reinserire la passphrase:

`Enter same passphrase again:`

Quindi premi Invio ancora una volta.

Ora dovresti avere una coppia di chiavi pubbliche e private di tipo RSA nella tua directory .ssh:

```
ls -a .ssh/
.  ..  id_rsa  id_rsa.pub
```

Ora abbiamo bisogno di inviare la chiave pubblica (id_rsa.pub) a ogni macchina a cui andremo ad accedere... ma prima di farlo, dobbiamo assicurarci di poter entrare in SSH nei server a cui invieremo la chiave. Per il nostro esempio, useremo solo tre server.

È possibile accedervi tramite SSH tramite un nome DNS o un indirizzo IP, ma per il nostro esempio useremo il nome DNS. I nostri server di esempio sono web, mail e portale. Per ogni server, cercheremo di SSH (i nerd amano usare SSH come un verbo) e lasciare una finestra del terminale aperta per ogni macchina:

`ssh -l root web.ourourdomain.com`

Supponendo che possiamo effettuare il login senza problemi su tutte e tre le macchine, il passo successivo è quello di inviare la nostra chiave pubblica su ogni server:

`scp .ssh/id_rsa.pub root@web.ourourdomain.com:/root/`

Ripetere questo passaggio con ciascuna delle nostre tre macchine.

In ciascuna delle finestre di terminale aperte, dovresti ora essere in grado di vedere *id_rsa.pub* quando inserisci il seguente comando:

`ls -a | grep id_rsa.pub`

Se così fosse, ora siamo pronti a creare o aggiungere il file *authorized_keys* nella directory *.ssh* di ogni server. Su ciascuno dei server, inserire questo comando:

`ls -a .ssh`

!!! warning "Importante!"

    Assicurati di leggere attentamente tutto ciò che segue. Se non siete sicuri di poter interrompere qualcosa, allora fate una copia di backup di authorized_keys (se esiste) su ciascuna delle macchine prima di continuare.

Se non c'è nessun file *authorized_keys* elencato, lo creeremo inserendo questo comando mentre siamo nella nostra directory _/root_:

`cat id_rsa.pub > .ssh/authorized_keys`

Se _authorized_keys_ esiste, dobbiamo semplicemente aggiungere la nostra nuova chiave pubblica a quelle che sono già lì:

`cat id_rsa.pub >> .ssh/authorized_keys`

Una volta che la chiave è stata aggiunta a _authorized_keys_, o il file _authorized_keys_ è stato creato, prova di nuovo a SSH dalla tua workstation Rocky Linux al server. Non vi dovrebbe richiedere una password.

Una volta verificato che è possibile accedere a SSH senza password, rimuovere il file id_rsa.pub dalla directory _/root_ di ogni macchina.

`rm id_rsa.pub`

## Directory SSH e Sicurezza authorized_keys

Su ciascuna delle macchine di destinazione, assicurati che siano applicate le seguenti autorizzazioni:

```
chmod 700 .ssh/
chmod 600 .ssh/authorized_keys
```
