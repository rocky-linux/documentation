---
title: rsync demo 01
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2021-12-25
---

# Premessa

`rsync` deve eseguire l'autenticazione dell'utente prima della sincronizzazione dei dati. **Ci sono due metodi di protocollo per l'autenticazione: protocollo SSH e protocollo rsync (la porta predefinita del protocollo rsync è la 873)**

* Metodo di verifica del protocollo SSH: usa il protocollo SSH come base per l'autenticazione dell'identità utente (cioè, utilizza l'utente del sistema e la password di GNU/Linux stesso per la verifica), e quindi esegue la sincronizzazione dei dati.
* metodo di verifica del protocollo rsync login: usa il protocollo rsync per l'autenticazione dell'identità utente (utenti di sistema non GNU/Linux, simili agli utenti virtuali vsftpd), e quindi esegue la sincronizzazione dei dati.

Prima della dimostrazione specifica della sincronizzazione rsync, è necessario utilizzare il comando `rsync`. In Rocky Linux 8, il pacchetto rpm rsync è installato per impostazione predefinita, e la versione è la 3.1.3-12, come segue:

```bash
[root@Rocky ~]# rpm -qa|grep rsync
rsync-3.1.3-12.el8.x86_64
```

```txt
Basic format: rsync [options] original location target location
Commonly used options:
-a: archive mode, recursive and preserves the attributes of the file object, which is equivalent to -rlptgoD (without -H, -A, -X)
-v: Display detailed information about the synchronization process
-z: compress when transferring files
-H: Keep hard link files
-A: retain ACL permissions
-X: retain chattr permissions
-r: Recursive mode, including all files in the directory and subdirectories
-l: still reserved for symbolic link files
-p: Permission to retain file attributes
-t: time to retain file attributes
-g: retain the group belonging to the file attribute (only for super users)
-o: retain the owner of the file attributes (only for super users)
-D: Keep device files and other special files
```

Uso personale dell'autore: `rsync -avz posizione originale posizione di destinazione`

## Descrizione dell'Ambiente

| Elemento              | Descrizione      |
| --------------------- | ---------------- |
| Rocky Linux 8(Server) | 192.168.100.4/24 |
| Fedora 34(client)     | 192.168.100.5/24 |

È possibile utilizzare Fedora 34 per caricare e scaricare

```mermaid
graph LR;
RockyLinux8-->|pull/download|Fedora34;
Fedora34-->|push/upload|RockyLinux8;
```

È inoltre possibile utilizzare Rocky Linux 8 per caricare e scaricare

```mermaid
graph LR;
RockyLinux8-->|push/upload|Fedora34;
Fedora34-->|pull/download|RockyLinux8;
```

## Dimostrazione basata sul protocollo SSH

!!! tip "Suggerimento"

    Qui, sia Rocky Linux 8 che Fedora 34 utilizzano l'utente root per accedere. Fedora 34 è il client e Rocky Linux 8 è il server.

### pull/scarica

Dato che si basa sul protocollo SSH, creiamo prima un utente nel server:

```bash
[root@Rocky ~]# useradd testrsync
[root@Rocky ~]# passwd testrsync
```

Sul lato client, lo tiriamo/scarichiamo e il file sul server è /rsync/aabbcc

```bash
[root@fedora ~]# rsync -avz testrsync@192.168.100.4:/rsync/aabbcc /root
testrsync@192.168.100.4 ' s password:
receiving incremental file list
aabbcc
sent 43 bytes received 85 bytes 51.20 bytes/sec
total size is 0 speedup is 0.00
[root@fedora ~]# cd
[root@fedora ~]# ls
aabbcc
```
Trasferimento effettuato con successo.

!!! tip "Suggerimento"

    Se la porta SSH del server non è quella predefinita la 22, puoi specificare la porta in modo simile ---`rsync -avz -e 'ssh -p [port]' `.

### push/carica

```bash
[root@fedora ~]# touch fedora
[root@fedora ~]# rsync -avz /root/* testrsync@192.168.100.4:/rsync/
testrsync@192.168.100.4 ' s password:
sending incremental file list
anaconda-ks.cfg
fedora
rsync: mkstemp " /rsync/.anaconda-ks.cfg.KWf7JF " failed: Permission denied (13)
rsync: mkstemp " /rsync/.fedora.fL3zPC " failed: Permission denied (13)
sent 760 bytes received 211 bytes 277.43 bytes/sec
total size is 883 speedup is 0.91
rsync error: some files/attrs were not transferred (see previous errors) (code 23) at main.c(1330) [sender = 3.2.3]
```

**Richiesta di autorizzazione negata, come gestirla?**

Prima controlla i permessi della directory /rsync/. Ovviamente, non c'è alcun permesso "w". Possiamo utilizzare `setfacl` per dare il permesso:

```bash
[root@Rocky ~ ] # ls -ld /rsync/
drwxr-xr-x 2 root root 4096 November 2 15:05 /rsync/
```

```bash
[root@Rocky ~ ] # setfacl -mu:testrsync:rwx /rsync/
[root@Rocky ~ ] # getfacl /rsync/
getfacl: Removing leading ' / ' from absolute path names
# file: rsync/
# owner: root
# group: root
user::rwx
user:testrsync:rwx
group::rx
mask::rwx
other::rx
```

Prova di nuovo, successo!

```bash
[root@fedora ~ ] # rsync -avz /root/* testrsync@192.168.100.4:/rsync/
testrsync@192.168.100.4 ' s password:
sending incremental file list
anaconda-ks.cfg
fedora
sent 760 bytes received 54 bytes 180.89 bytes/sec
total size is 883 speedup is 1.08
```
