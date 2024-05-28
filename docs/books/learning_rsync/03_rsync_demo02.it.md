---
title: rsync demo 02
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2021-12-25
---

# Dimostrazione basata sul protocollo rsync

In vsftpd, ci sono utenti virtuali (utenti impersonali personalizzati dall'amministratore) perché non è sicuro usare utenti anonimi e utenti locali. Sappiamo che un server basato sul protocollo SSH deve garantire che ci sia un sistema di utenti. Quando ci sono molti requisiti di sincronizzazione, può essere necessario creare molti utenti. Questo ovviamente non soddisfa gli standard di gestione e manutenzione GNU/Linux (più utenti, più insicuro), in rsync, per motivi di sicurezza, c'è un metodo di autenticazione il protocollo rsync.

**Come farlo?**

È sufficiente scrivere i parametri e i valori corrispondenti nel file di configurazione. In Rocky Linux 8, è necessario creare manualmente il file <font color=red>/etc/rsyncd.conf</font>.

```bash
[root@Rocky ~]# touch /etc/rsyncd.conf
[root@Rocky ~]# vim /etc/rsyncd.conf
```

Alcuni parametri e valori di questo file sono i seguenti, [qui](04_rsync_configure.md) si trovano altre descrizioni dei parametri:

| Elemento                                  | Descrizione                                                                                                                                                                     |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| address = 192.168.100.4                   | L'indirizzo IP dove rsync è in ascolto di default                                                                                                                               |
| port = 873                                | porta rsync di ascolto predefinita                                                                                                                                              |
| pid file = /var/run/rsyncd.pid            | Posizione del file del pid del processo                                                                                                                                         |
| log file = /var/log/rsyncd.log            | Posizione del file del registro                                                                                                                                                 |
| [share]                                   | Nome condiviso                                                                                                                                                                  |
| comment = rsync                           | Osservazioni e informazioni sulla descrizione                                                                                                                                   |
| path = /rsync/                            | Posizione del percorso di sistema in cui si trova                                                                                                                               |
| read only = yes                           | sì significa solo leggere, non leggere e scrivere                                                                                                                               |
| dont compress = \*.gz \*.gz2 \*.zip | Quali tipi di file non comprimere                                                                                                                                               |
| auth users = li                           | Abilita gli utenti virtuali e definisci come viene chiamato un utente virtuale. Devi crearlo da solo                                                                            |
| secrets file = /etc/rsyncd_users.db       | Usato per specificare la posizione del file password dell'utente virtuale, che deve terminare in .db. Il formato del contenuto del file è "Nome utente: Password", uno per riga |

!!! tip "Suggerimento!"

    L'autorizzazione del file della password deve essere <font color=red>600</font>.

Scrivi il contenuto del file su <font color=red>/etc/rsyncd.conf</font>e scrivi il nome utente e la password su /etc/rsyncd_users.db, il permesso è 600

```bash
[root@Rocky ~]# cat /etc/rsyncd.conf
address = 192.168.100.4
port = 873
pid file = /var/run/rsyncd.pid
log file = /var/log/rsyncd.log
[share]
comment = rsync
path = /rsync/
read only = yes
dont compress = *.gz *.bz2 *.zip
auth users = li
secrets file = /etc/rsyncd_users.db
[root@Rocky ~]# ll /etc/rsyncd_users.db
-rw------- 1 root root 9 November 2 16:16 /etc/rsyncd_users.db
[root@Rocky ~]# cat /etc/rsyncd_users.db
li:13579
```

Potrebbe essere necessario `dnf -y install rsync-daemon` prima di poter avviare il servizio: `systemctl start rsyncd.service`

```bash
[root@Rocky ~]# systemctl start rsyncd.service
[root@Rocky ~]# netstat -tulnp
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      691/sshd            
tcp        0      0 192.168.100.4:873       0.0.0.0:*               LISTEN      4607/rsync          
tcp6       0      0 :::22                   :::*                    LISTEN      691/sshd            
udp        0      0 127.0.0.1:323           0.0.0.0:*                           671/chronyd         
udp6       0      0 ::1:323                 :::*                                671/chronyd  
```

## pull/scarica

Crea un file nel server per la verifica: `[root@Rocky]# touch /rsync/rsynctest.txt`

Il client fa quanto segue:

```bash
[root@fedora ~]# rsync -avz li@192.168.100.4::share /root
Password:
receiving incremental file list
./
rsynctest.txt
sent 52 bytes received 195 bytes 7.16 bytes/sec
total size is 883 speedup is 3.57
[root@fedora ~]# ls
aabbcc anaconda-ks.cfg fedora rsynctest.txt
```

successo! Oltre alla scrittura precedente basata sul protocollo rsync, puoi anche scrivere così: `rsync://li@10.1.2.84/share`

## push/carica

```bash
[root@fedora ~]# touch /root/fedora.txt
[root@fedora ~]# rsync -avz /root/* li@192.168.100.4::share
Password:
sending incremental file list
rsync: [sender] read error: Connection reset by peer (104)
rsync error: error in socket IO (code 10) at io.c(784) [sender = 3.2.3]
```

Vieni informato che l'errore di lettura è relativo al "read only = yes" del server. Cambialo in "no" e riavvia il servizio `[root@Rocky ~]# systemctl restart rsyncd.service`

Prova di nuovo, ti viene negato il permesso:

```bash
[root@fedora ~]# rsync -avz /root/* li@192.168.100.4::share
Password:
sending incremental file list
fedora.txt
rsync: mkstemp " /.fedora.txt.hxzBIQ " (in share) failed: Permission denied (13)
sent 206 bytes received 118 bytes 92.57 bytes/sec
total size is 883 speedup is 2.73
rsync error: some files/attrs were not transferred (see previous errors) (code 23) at main.c(1330) [sender = 3.2.3]
```

Il nostro utente virtuale qui è <font color=red>li</font>, che viene mappato all'utente di sistema <font color=red>nobody</font> per impostazione predefinita. Naturalmente, è possibile cambiarlo in altri utenti del sistema. In altre parole, nobody non ha il permesso di scrittura nella directory /rsync/. Naturalmente, possiamo usare `[root@Rocky ~]# setfacl -mu:nobody:rwx /rsync/` , riprovare, e avere successo.

```bash
[root@fedora ~]# rsync -avz /root/* li@192.168.100.4::share
Password:
sending incremental file list
fedora.txt
sent 206 bytes received 35 bytes 96.40 bytes/sec
total size is 883 speedup is 3.66
```
