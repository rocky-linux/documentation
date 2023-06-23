---
title: rsync login senza password
author: tianci li
contributors: Steven Spencer, Franco Colussi
update: 2021-12-26
---

# Prefazione

Da [rsync Breve Descrizione](01_rsync_overview.md) sappiamo che rsync è uno strumento di sincronizzazione incrementale. Ogni volta che viene eseguito il comando `rsync`, i dati possono essere sincronizzati una volta, ma i dati non possono essere sincronizzati in tempo reale. Come farlo?

Con inotify-tools, questo strumento può realizzare la sincronizzazione unidirezionale in tempo reale. Poiché si tratta di sincronizzazione dati in tempo reale, il prerequisito è quello di accedere senza autenticazione con password.

**Indipendentemente dal fatto che si tratti di protocollo rsync o protocollo SSH, entrambi possono ottenere l'accesso all'autenticazione senza password.**

## Accesso all'autenticazione senza password del protocollo SSH

Innanzitutto, genera una chiave pubblica e una coppia di chiavi private sul client e continua a premere Invio dopo aver digitato il comando. La coppia di chiavi viene salvata nella directory <font color=red>/root/.ssh/</font>.

```bash
[root@fedora ~]# ssh-keygen -t rsa -b 2048
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /root/.ssh/id_rsa
Your public key has been saved in /root/.ssh/id_rsa.pub
The key fingerprint is:
SHA256: TDA3tWeRhQIqzTORLaqy18nKnQOFNDhoAsNqRLo1TMg root@fedora
The key's randomart image is:
+---[RSA 2048]----+
|O+. +o+o. .+. |
|BEo oo*....o. |
|*o+o..*.. ..o |
|.+..o. = o |
|o o S |
|. o |
| o +. |
|....=. |
| .o.o. |
+----[SHA256]-----+
```

Quindi, utilizza il comando `scp` per caricare il file della chiave pubblica sul server. Per esempio, carica questa chiave pubblica dell'utente **testrsync**

```bash
[root@fedora ~]# scp -P 22 /root/.ssh/id_rsa.pub root@192.168.100.4:/home/testrsync/
```

```bash
[root@Rocky ~]# cat /home/testrsync/id_rsa.pub >> /home/testrsync/.ssh/authorized_keys
```

Prova ad accedere senza autenticazione segreta, successo!

```bash
[root@fedora ~]# ssh -p 22 testrsync@192.168.100.4
Last login: Tue Nov 2 21:42:44 2021 from 192.168.100.5
[testrsync@Rocky ~]$
```

!!! tip "Suggerimento!"

    Il file di configurazione del server **/etc/ssh/sshd_config** dovrebbe essere aperto <font color=red>PubkeyAuthentication yes</font>

## rsync protocollo di autenticazione senza password

Dal lato client, il servizio rsync prepara una variabile di ambiente per il sistema-**RSYNC_PASSWORD**, che è vuoto per impostazione predefinita, come mostrato sotto:

```bash
[root@fedora ~]# echo "$RSYNC_PASSWORD"

[root@fedora ~]#
```

Se si desidera ottenere l'accesso all'autenticazione senza password, è sufficiente assegnare un valore a questa variabile. Il valore assegnato è la password precedentemente impostata per l'utente virtuale <font color=red>li</font>. Allo stesso tempo, dichiara questa variabile come una variabile globale.

```bash
[root@Rocky ~]# cat /etc/rsyncd_users.db
li:13579
```

```bash
[root@fedora ~]# export RSYNC_PASSWORD=13579
```

Provalo, successo! Nessun nuovo file appare qui, quindi l'elenco dei file trasferiti non è visualizzato.

```bash
[root@fedora ~]# rsync -avz li@192.168.100.4::share /root/
receiving incremental file list
./

sent 30 bytes received 193 bytes 148.67 bytes/sec
total size is 883 speedup is 3.96
```

!!! tip "Suggerimento!"

    Puoi scrivere questa variabile in **/etc/profile** per renderla efficace in modo permanente. Il contenuto è: `export RSYNC_PASSWORD=13579`
