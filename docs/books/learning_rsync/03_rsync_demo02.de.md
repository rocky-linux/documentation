---
title: rsync – Demo 02
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2021-11-04
---

# Demo basierend auf dem rsync-Protokoll

In `vsftpd` gibt es virtuelle Benutzer (durch den Administrator angepasste Benutzer), weil es nicht sicher ist, anonyme Benutzer und lokale Benutzer zu verwenden. Wir wissen, dass ein Server, der auf dem `SSH`-Protokoll basiert, sicherstellen muss, dass es ein System von Benutzern gibt. Wenn es viele Synchronisationsanforderungen gibt, kann es notwendig sein, viele Benutzer zu erstellen. Dies entspricht natürlich nicht den GNU/Linux-Betriebssystem- und Wartungsstandards (je mehr Benutzer Je unsicherer). In `rsync`, aus Sicherheitsgründen gibt es eine Anmeldemethode für `rsync`-Protokollauthentifizierung.

**Wie macht man das?**

Geben Sie einfach die entsprechenden Parameter und Werte in die Konfigurationsdatei ein. In Rocky Linux 8 müssen Sie die Datei <font color=red>/etc/rsyncd.conf</font> manuell erstellen.

```bash
[root@Rocky ~]# touch /etc/rsyncd.conf
[root@Rocky ~]# vim /etc/rsyncd.conf
```

Einige Parameter und Werte dieser Datei lauten wie folgt, [hier](04_rsync_configure.md) finden Sie weitere Parameterinfos:

| Item                                      | Beschreibung                                                                                                                                                                                 |
| ----------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| address = 192.168.100.4                   | Die IP-Adresse, auf die rsync default-mäßig lauscht                                                                                                                                          |
| port = 873                                | Standardmäßig lauscht der `rsync`-Daemon auf diesem Port                                                                                                                                   |
| pid file = /var/run/rsyncd.pid            | Datei-Speicherort der Prozess-PID                                                                                                                                                            |
| log file = /var/log/rsyncd.log            | Speicherort des Log-Protokolls                                                                                                                                                               |
| [share]                                   | Freigabename                                                                                                                                                                                 |
| comment = rsync                           | Hinweise oder Beschreibungsinformationen                                                                                                                                                     |
| path = /rsync/                            | Der Systempfad dort, wo er sich befindet                                                                                                                                                     |
| read only = yes                           | yes bedeutet nur lesen, kein schreiben                                                                                                                                                       |
| dont compress = \*.gz \*.gz2 \*.zip | Welche Dateitypen werden nicht komprimiert                                                                                                                                                   |
| auth users = li                           | Virtuelle Benutzer aktivieren und definieren, wie ein virtueller Benutzer genannt wird. Sie sollten es selbst erstellen                                                                      |
| secrets file = /etc/rsyncd_users.db       | Wird verwendet, um den Speicherort der Passwortdatei des virtuellen Benutzers anzugeben, die mit `.db` enden muss. Das Inhaltsformat der Datei ist "Benutzername: Passwort" für jede Zeile |

!!! tip "Tip"

    Die Berechtigung für die Passwortdatei muss <font color=red>600</font> sein.

Schreiben Sie einen Teil des Dateiinhalts in <font color=red>/etc/rsyncd.conf</font> und schreiben Sie den Benutzernamen und das Passwort in /etc/rsyncd_users.db. Die Berechtigung beträgt 600

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

Sie müssen möglicherweise `dnf -y rsync-daemon install` ausführen bevor Sie den Dienst starten können: `systemctl start rsyncd.service`

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

## pull/download

Eine Datei auf dem Server zur Verifikation erstellen: `[root@Rocky]# touch /rsync/rsynctest.txt`

Der Client macht folgendes:

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

success! Zusätzlich zum obigen Schreiben basierend auf dem rsync-Protokoll können Sie folgendermaßen schreiben: `rsync://li@10.1.2.84/share`

## push/upload

```bash
[root@fedora ~]# touch /root/fedora.txt
[root@fedora ~]# rsync -avz /root/* li@192.168.100.4::share
Password:
sending incremental file list
rsync: [sender] read error: Connection reset by peer (104)
rsync error: error in socket IO (code 10) at io.c(784) [sender = 3.2.3]
```

Sie erhalten den Hinweis, dass der Lesefehler mit der Einstellung `read only = yes` des Servers zusammenhängt. Ändern Sie es auf `no` und starten Sie den Dienst neu:<br/> `[root@Rocky ~]# systemctl restart rsyncd.service`

Versuchen Sie es noch einmal und Sie erhalten die Meldung, dass die Berechtigung verweigert wurde:

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

Unser virtueller Benutzer hier ist <font color=red>li</font>, der standardmäßig dem Systembenutzer <font color=red>nobody</font> zugeordnet ist. Natürlich können Sie dies auf andere Systembenutzer umstellen. Mit anderen Worten, `nobody` hat keine Schreibberechtigung in das Verzeichnis `/rsync/`. Natürlich können Sie `[root@Rocky ~]# setfacl -mu:nobody:rwx /rsync/` verwenden, und es erneut versuchen.

```bash
[root@fedora ~]# rsync -avz /root/* li@192.168.100.4::share
Password:
sending incremental file list
fedora.txt
sent 206 bytes received 35 bytes 96.40 bytes/sec
total size is 883 speedup is 3.66
```
