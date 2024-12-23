---
title: rsync-Demo 01
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2021-11-04
---

# Vorwort

`rsync` muss vor der Datensynchronisierung eine Benutzerauthentifizierung durchführen. **Es gibt zwei Protokollmethoden für die Authentifizierung: SSH-Protokoll und rsync-Protokoll (der Standardport des rsync-Protokolls ist 873)**

* Login-Methode mit SSH-Protokollüberprüfung: Benutzen Sie das SSH-Protokoll als Basis für die Authentifizierung der Benutzeridentität (d.h. verwenden Sie den Systembenutzer und das Passwort zur Verifizierung) und führen Sie dann die Datensynchronisierung durch.
* Login-Methode für rsync-Protokollüberprüfung: Benutzen Sie das `rsync`-Protokoll für die Authentifizierung (Benutzer, die keine GNU/Linux-Systembenutzer sind, ähnlich wie vsftpd-virtuelle Benutzer), und führen Sie dann die Datensynchronisierung durch.

Vor der spezifischen Demonstration der rsync-Synchronisierung müssen Sie den Befehl `rsync` verwenden. In Rocky Linux 8 ist das rsync-rpm-Paket standardmäßig installiert und die Version 3.1.3-12 ist wie folgt:

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

Persönliche Verwendung durch den Autor: `rsync -avz Originalstandort Zielstandort`

## Umgebungsbeschreibung

| Item                   | Beschreibung     |
| ---------------------- | ---------------- |
| Rocky Linux 8 (Server) | 192.168.100.4/24 |
| Fedora 34 (Client)     | 192.168.100.5/24 |

Sie können Fedora 34 zum Hochladen und Herunterladen verwenden

```mermaid
graph LR;
RockyLinux8-->|pull/download|Fedora34;
Fedora34-->|push/upload|RockyLinux8;
```

Sie können Rocky Linux 8 auch zum Hochladen und Herunterladen verwenden

```mermaid
graph LR;
RockyLinux8-->|push/upload|Fedora34;
Fedora34-->|pull/download|RockyLinux8;
```

## Demonstration basierend auf SSH-Protokoll

!!! tip "Hinweis"

    Hier verwenden sowohl Rocky Linux 8 als auch Fedora 34 den root-Benutzer, um sich einzuloggen. In diesem Beispiel ist Fedora 34 der Client und Rocky Linux 8 der Server.

### pull/download

Da es auf dem SSH-Protokoll basiert, erstellen wir zuerst einen Benutzer auf dem Server:

```bash
[root@Rocky ~]# useradd testrsync
[root@Rocky ~]# passwd testrsync
```

Auf der Client-Seite wird es heruntergeladen, und die Datei auf dem Server ist /rsync/aabbcc

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

Die Übertragung war erfolgreich.

!!! tip "Tip"

    Wenn der SSH-Port des Servers nicht der Standard ist, 22, können Sie den Port wie folgt angeben: `rsync -avz -e 'ssh -p [port]'.

### push/upload

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

**Eingabeaufforderung verweigert, wie Sie damit umzugehen sollten?**

Überprüfen Sie zuerst die Berechtigungen des /rsync/ Verzeichnisses. Offensichtlich gibt es keine "w"-Berechtigung. Wir können `setfacl` verwenden, um die Berechtigung zu erteilen:

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

Versuchen Sie es noch einmal!

```bash
[root@fedora ~ ] # rsync -avz /root/* testrsync@192.168.100.4:/rsync/
testrsync@192.168.100.4 ' s password:
sending incremental file list
anaconda-ks.cfg
fedora
sent 760 bytes received 54 bytes 180.89 bytes/sec
total size is 883 speedup is 1.08
```
