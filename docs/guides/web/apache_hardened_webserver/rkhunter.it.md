---
title: Rootkit Hunter
author: Steven Spencer
contributors: Ezequiel Bruni, Andrew Thiesen, Ganna Zhyrnova
tested_with: 8.8, 9.2
tags:
  - server
  - security
  - rkhunter
---

# Rootkit hunter

## Introduzione

Rootkit hunter (`rkhunter`) è uno strumento ben noto per verificare vulnerabilità, rootkit, backdoor e possibili exploit locali su un server. È possibile utilizzarlo su _qualsiasi_ server utilizzato per _qualsiasi_ scopo. Se messo a punto e automatizzato, può segnalare qualsiasi attività sospetta all'amministratore del sistema. Questa procedura illustra l'installazione, la messa a punto e l'uso di rootkit hunter.

`rkhunter` è solo una delle possibili parti di una configurazione di un server protetto. Utilizzatelo da solo o con altri strumenti per massimizzare la sicurezza.

## Prerequisiti

* Conoscenza di un editor a riga di comando (in questo esempio si usa `vi` )
* Un livello di confidenza con l'emissione di comandi dalla riga di comando, la visualizzazione dei log e altre mansioni generali di amministratore di sistema
* È utile la comprensione di ciò che può innescare una risposta ai file modificati sul file system (come gli aggiornamenti dei pacchetti)
* Esecuzione di tutti i comandi come root o come utente normale con `sudo`

Questo documento è stato originariamente scritto in combinazione con le routine del server web hardened apache, ma funziona ugualmente bene su un server che esegue qualsiasi software.

## Fasi generali

1. installare `rkhunter`
2. configurare `rkhunter`
3. configurare la posta elettronica e assicurarsi che funzioni correttamente
4. eseguire manualmente `rkhunter` per generare un elenco di avvisi per testare le impostazioni della posta elettronica`(rkhunter --check`)
5. eseguire `rkhunter --propupd` per generare un file `rkhunter.dat` pulito che `rkhunter` utilizzerà da questo momento in poi come base per ulteriori controlli.

## Installazione di `rkhunter`

`rkhunter` richiede il repository EPEL (Extra Packages for Enterprise Linux). Installare il repository se non è già installato:

```bash
dnf install epel-release
```

Installare `rkhunter`:

```bash
dnf install rkhunter
```

## Configurazione di `rkhunter`

Le uniche opzioni di configurazione _necessarie_ da impostare sono quelle relative all'invio dei rapporti all'Amministratore.

!!! warning "Attenzione"

    La modifica di _qualsiasi_ file di configurazione in Linux comporta dei rischi. Prima di modificare **qualsiasi** file di configurazione in Linux, si raccomanda di creare un backup del file _originale_.

Per modificare il file di configurazione, eseguire:

```bash
vi /etc/rkhunter.conf
```

Cerca:

```bash
#MAIL-ON-WARNING=me@mydomain   root@mydomain
```

Rimuovere il commento qui e modificare il `me@mydomain.com` in modo che rifletta il vostro indirizzo e-mail.

Cambiare `root@mydomain` in `root@whatever_the_server_name_is`.

Probabilmente si vorrà anche rimuovere il commento (e modificare la riga per adattarla alle proprie esigenze) dalla riga `MAIL-CMD`:

```bash
MAIL_CMD=mail -s "[rkhunter] Warnings found for ${HOST_NAME}"
```

Potrebbe essere necessario impostare [Postfix Email for Reporting](../../email/postfix_reporting.md) per far funzionare correttamente la sezione e-mail.

## Esecuzione di `rkhunter`

Eseguire manualmente `rkhunter` digitandolo dalla riga di comando. Un cron job si occupa di eseguire automaticamente `rkhunter` in `/etc/cron.daily`. Se si desidera automatizzare la procedura su una pianificazione diversa, consultare la [guida all'automatizzazione dei processi cron](../../automation/cron_jobs_howto.md).

È inoltre necessario spostare lo script in un luogo diverso da `/etc/cron.daily/`, ad esempio `/usr/local/sbin/` e richiamarlo dal cron job personalizzato. Il metodo più semplice è quello di lasciare intatta l'impostazione predefinita di `cron.daily.`

Se si desidera testare `rkhunter` prima di iniziare, comprese tutte le funzionalità di posta elettronica, eseguire `rkhunter --check` dalla riga di comando. Se l'installazione e il funzionamento sono corretti, si dovrebbe ricevere un risultato simile al seguente:

```bash
[root@sol admin]# rkhunter --check
[Rootkit Hunter version 1.4.6]

Checking system commands...

Performing 'strings' command checks
- Checking 'strings' command                               [OK]

Performing 'shared libraries' checks
- Checking for preloading variables                        [None found]
- Checking for preloaded libraries                         [None found]
- Checking LD_LIBRARY_PATH variable                        [Not found]

Performing file properties checks
- Checking for prerequisites                               [Warning]
- /usr/bin/awk                                             [OK]
- /usr/bin/basename                                        [OK]
- /usr/bin/bash                                            [OK]
- /usr/bin/cat                                             [OK]
- /usr/bin/chattr                                          [OK]
- /usr/bin/chmod                                           [OK]
- /usr/bin/chown                                           [OK]
- /usr/bin/cp                                              [OK]
- /usr/bin/curl                                            [OK]
- /usr/bin/cut                                             [OK]
- /usr/bin/date                                            [OK]
- /usr/bin/df                                              [OK]
- /usr/bin/diff                                            [OK]
- /usr/bin/dirname                                         [OK]
- /usr/bin/dmesg                                           [OK]
- /usr/bin/du                                              [OK]
- /usr/bin/echo                                            [OK]
- /usr/bin/ed                                              [OK]
- /usr/bin/egrep                                           [Warning]
- /usr/bin/env                                             [OK]
- /usr/bin/fgrep                                           [Warning]
- /usr/bin/file                                            [OK]
- /usr/bin/find                                            [OK]
- /usr/bin/GET                                             [OK]
- /usr/bin/grep                                            [OK]
- /usr/bin/groups                                          [OK]
- /usr/bin/head                                            [OK]
- /usr/bin/id                                              [OK]
- /usr/bin/ipcs                                            [OK]
- /usr/bin/kill                                            [OK]
- /usr/bin/killall                                         [OK]
- /usr/bin/last                                            [OK]
- /usr/bin/lastlog                                         [OK]
- /usr/bin/ldd                                             [OK]
- /usr/bin/less                                            [OK]
- /usr/bin/locate                                          [OK]
- /usr/bin/logger                                          [OK]
- /usr/bin/login                                           [OK]
- /usr/bin/ls                                              [OK]
- /usr/bin/lsattr                                          [OK]
- /usr/bin/lsof                                            [OK]
- /usr/bin/mail                                            [OK]
- /usr/bin/md5sum                                          [OK]
- /usr/bin/mktemp                                          [OK]
- /usr/bin/more                                            [OK]
- /usr/bin/mount                                           [OK]
- /usr/bin/mv                                              [OK]
- /usr/bin/netstat                                         [OK]
- /usr/bin/newgrp                                          [OK]
- /usr/bin/passwd                                          [OK]
- /usr/bin/perl                                            [OK]
- /usr/bin/pgrep                                           [OK]
- /usr/bin/ping                                            [OK]
- /usr/bin/pkill                                           [OK]
- /usr/bin/ps                                              [OK]
- /usr/bin/pstree                                          [OK]
- /usr/bin/pwd                                             [OK]
- /usr/bin/readlink                                        [OK]
- /usr/bin/rkhunter                                        [OK]
- /usr/bin/rpm                                             [OK]
- /usr/bin/runcon                                          [OK]
- /usr/bin/sed                                             [OK]
- /usr/bin/sestatus                                        [OK]
- /usr/bin/sh                                              [OK]
- /usr/bin/sha1sum                                         [OK]
- /usr/bin/sha224sum                                       [OK]
- /usr/bin/sha256sum                                       [OK]
- /usr/bin/sha384sum                                       [OK]
- /usr/bin/sha512sum                                       [OK]
- /usr/bin/size                                            [OK]
- /usr/bin/sort                                            [OK]
- /usr/bin/ssh                                             [OK]
- /usr/bin/stat                                            [OK]
- /usr/bin/strace                                          [OK]
- /usr/bin/strings                                         [OK]
- /usr/bin/su                                              [OK]
- /usr/bin/sudo                                            [OK]
- /usr/bin/tail                                            [OK]
- /usr/bin/test                                            [OK]
- /usr/bin/top                                             [OK]
- /usr/bin/touch                                           [OK]
- /usr/bin/tr                                              [OK]
- /usr/bin/uname                                           [OK]
- /usr/bin/uniq                                            [OK]
- /usr/bin/users                                           [OK]
- /usr/bin/vmstat                                          [OK]
- /usr/bin/w                                               [OK]
- /usr/bin/watch                                           [OK]
- /usr/bin/wc                                              [OK]
- /usr/bin/wget                                            [OK]
- /usr/bin/whatis                                          [OK]
- /usr/bin/whereis                                         [OK]
- /usr/bin/which                                           [OK]
- /usr/bin/who                                             [OK]
- /usr/bin/whoami                                          [OK]
- /usr/bin/numfmt                                          [OK]
- /usr/bin/gawk                                            [OK]
- /usr/bin/s-nail                                          [OK]
- /usr/bin/whatis.man-db                                   [OK]
- /usr/bin/kmod                                            [OK]
- /usr/bin/systemctl                                       [OK]
- /usr/sbin/adduser                                        [OK]
- /usr/sbin/chroot                                         [OK]
- /usr/sbin/depmod                                         [OK]
- /usr/sbin/fsck                                           [OK]
- /usr/sbin/fuser                                          [OK]
- /usr/sbin/groupadd                                       [OK]
- /usr/sbin/groupdel                                       [OK]
- /usr/sbin/groupmod                                       [OK]
- /usr/sbin/grpck                                          [OK]
- /usr/sbin/ifconfig                                       [OK]
- /usr/sbin/init                                           [OK]
- /usr/sbin/insmod                                         [OK]
- /usr/sbin/ip                                             [OK]
- /usr/sbin/lsmod                                          [OK]
- /usr/sbin/modinfo                                        [OK]
- /usr/sbin/modprobe                                       [OK]
- /usr/sbin/nologin                                        [OK]
- /usr/sbin/ping                                           [OK]
- /usr/sbin/pwck                                           [OK]
- /usr/sbin/rmmod                                          [OK]
- /usr/sbin/route                                          [OK]
- /usr/sbin/rsyslogd                                       [OK]
- /usr/sbin/runlevel                                       [OK]
- /usr/sbin/sestatus                                       [OK]
- /usr/sbin/sshd                                           [OK]
- /usr/sbin/sulogin                                        [OK]
- /usr/sbin/sysctl                                         [OK]
- /usr/sbin/useradd                                        [OK]
- /usr/sbin/userdel                                        [OK]
- /usr/sbin/usermod                                        [OK]
- /usr/sbin/vipw                                           [OK]
- /usr/libexec/gawk                                        [OK]
- /usr/lib/systemd/systemd                                 [OK]

[Press <ENTER> to continue]
```

Se ci sono problemi con l'impostazione dell'e-mail, non completate i passaggi restanti. Quando l'e-mail di conferma funziona, ma prima di consentire l'esecuzione automatica di `rkhunter`, eseguire nuovamente il comando manualmente con il flag "--propupd" per creare il file `rkhunter.dat.`  Ciò garantisce il riconoscimento dell'ambiente e della configurazione:

```bash
rkhunter --propupd
```

## Conclusione

`rkhunter` è una parte di una strategia di server rinforzato che può aiutare a monitorare il file system e a segnalare eventuali problemi all'amministratore. È forse uno degli strumenti di hardening più semplici da installare, configurare ed eseguire.
