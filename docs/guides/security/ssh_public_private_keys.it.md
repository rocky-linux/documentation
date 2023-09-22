---
title: SSH Chiave Pubblica e Privata
author: Spencer Steven
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5
tags:
  - security
  - ssh
  - keygen
---

# SSH Chiave Pubblica e Privata

## Prerequisiti

* Una certa comodità nell'operare dalla riga di comando
* Un server Linux o workstation con *openssh* installato
* Facoltativo: familiarità con i permessi di file Linux e directory

## Introduzione

SSH è un protocollo per accedere a una macchina da un'altra, di solito tramite la riga di comando. Con SSH è possibile eseguire comandi su computer e server remoti, inviare file e in genere gestire tutto ciò che si fa da un unico posto.

Quando si lavora con molti server Rocky Linux in varie località o si cerca di risparmiare tempo per accedere a questi server, è necessario utilizzare una coppia di chiavi pubbliche e private SSH. Le coppie di chiavi facilitano l'accesso ai computer remoti e l'esecuzione dei comandi.

Questo documento vi guiderà nella creazione delle chiavi e nell'impostazione dei server per l'accesso con tali chiavi.

## Processo per generare le chiavi

I seguenti comandi sono tutti eseguiti dalla riga di comando della workstation Rocky Linux:

```
ssh-keygen -t rsa
```

Che mostrerà quanto segue:

```
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
```

Premete <kbd>INVIO</kbd> per accettare la posizione predefinita. Successivamente il sistema mostrerà:

`Enter passphrase (empty for no passphrase):`

Premete <kbd>INVIO</kbd> qui. Infine, vi chiederà di reinserire la passphrase:

`Enter same passphrase again:`

Premete <kbd>INVIO</kbd> un'ultima volta.

Ora avrete una coppia di chiavi pubbliche e private di tipo RSA nella vostra directory *.ssh*:

```
ls -a .ssh/
.  ..  id_rsa  id_rsa.pub
```

È necessario inviare la chiave pubblica (*id_rsa.pub*) a ogni macchina a cui si intende accedere. Prima di fare ciò, è necessario assicurarsi di poter accedere via SSH ai server a cui si sta inviando la chiave. Questo esempio utilizza tre server.

È possibile accedervi con SSH tramite nome DNS o indirizzo IP, ma in questo esempio si utilizza il nome DNS. I server di esempio sono web, mail e portal. Per ogni server, si effettua l'accesso SSH (i nerd amano usare SSH come verbo) e si lascia aperta una finestra di terminale:

`ssh -l root web.ourourdomain.com`

Se si riesce a effettuare il login senza problemi su tutti e tre i computer, il passo successivo è inviare la chiave pubblica a ciascun server. Per farlo, utilizzare il comando `ssh-copy-id`:

`ssh-copy-id -i ~/.ssh/id_rsa.pub` user@web.ourdomain.com

Ripetere questa operazione con ciascuna delle tre macchine. Questo popolerà il file *authorized_keys* su ogni server con la chiave pubblica.

Provare di nuovo a eseguire l'SSH dalla workstation Rocky Linux al server. Non dovrebbe essere richiesta alcuna password.

## Directory SSH e sicurezza `authorized_keys`

Su ciascuno dei computer di destinazione, assicurarsi che vengano applicate le seguenti autorizzazioni:

```
chmod 700 .ssh/
chmod 600 .ssh/authorized_keys
```
