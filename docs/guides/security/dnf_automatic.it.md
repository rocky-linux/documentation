---
title: Patching con dnf-automatic
author: Antoine Le Morvan
contributors: Steven Spencer, Franco Colussi
tested_with: 8.5
tags:
  - security
  - dnf
  - automation
  - updates
---

# Patching dei server con `dnf-automatic`

La gestione dell'installazione degli aggiornamenti di sicurezza è una questione importante per l'amministratore di sistema. Il processo di fornitura degli aggiornamenti software è una strada ben consolidata che alla fine causa pochi problemi. Per questi motivi, è ragionevole automatizzare il download e l'applicazione degli aggiornamenti quotidianamente e automaticamente sui server Rocky.

La sicurezza del vostro sistema informatico sarà rafforzata. `dnf-automatic` è uno strumento aggiuntivo che consente di raggiungere questo obiettivo.

!!! tip "Se siete preoccupati..."

    Anni fa, applicare automaticamente gli aggiornamenti in questo modo sarebbe stata una ricetta per il disastro. In molti casi l'applicazione di un aggiornamento potrebbe causare problemi. Questo accade ancora raramente, quando l'aggiornamento di un pacchetto rimuove una funzionalità deprecata che viene utilizzata sul server, ma per la maggior parte, questo non è un problema al giorno d'oggi. Detto questo, se non vi sentite ancora a vostro agio nel lasciare che sia `dnf-automatic` a gestire gli aggiornamenti, prendete in considerazione la possibilità di usarlo per scaricare e/o notificare la disponibilità di aggiornamenti. In questo modo il vostro server non rimarrà a lungo senza patch. Queste caratteristiche sono `dnf-automatic-notifyonly` e `dnf-automatic-download`.
    
    Per saperne di più su queste funzioni, consultare la [documentazione ufficiale](https://dnf.readthedocs.io/en/latest/automatic.html).

## Installazione

Puoi installare `dnf-automatic` dai repository rocky:

```
sudo dnf install dnf-automatic
```

## Configurazione

Per impostazione predefinita, il processo di aggiornamento inizierà alle 6 del mattino, con un delta temporale aggiuntivo casuale per evitare che tutte le macchine vengano aggiornate alla stessa ora. Per modificare questo comportamento, è necessario sovrascrivere la configurazione del timer associata al servizio applicativo:

```
sudo systemctl edit dnf-automatic.timer

[Unit]
Description=dnf-automatic timer
# See comment in dnf-makecache.service
ConditionPathExists=!/run/ostree-booted
Wants=network-online.target

[Timer]
OnCalendar=*-*-* 6:00
RandomizedDelaySec=10m
Persistent=true

[Install]
WantedBy=timers.target
```

Questa configurazione riduce il ritardo di avvio tra le 6:00 e le 6:10. (Un server che viene spento in questo momento viene automaticamente patchato dopo il suo riavvio.)

Quindi attivare il timer associato al servizio (non il servizio stesso):

```
$ sudo systemctl enable --now dnf-automatic.timer
```

## Che dire dei server CentOS 7?

!!! tip "Suggerimento"

    Sì, questa è la documentazione di Rocky Linux, ma se siete amministratori di sistema o di rete, potreste avere qualche macchina CentOS 7 ancora in funzione. Lo capiamo ed è per questo che abbiamo inserito questa sezione.

Il processo sotto CentOS 7 è simile ma usa: `yum-cron`.

```
$ sudo yum install yum-cron
```

La configurazione del servizio viene effettuata questa volta nel file `/etc/yum/yum-cron.conf`.

Impostare la configurazione come necessario:

```
[commands]
#  What kind of update to use:
# default                            = yum upgrade
# security                           = yum --security upgrade
# security-severity:Critical         = yum --sec-severity=Critical upgrade
# minimal                            = yum --bugfix update-minimal
# minimal-security                   = yum --security update-minimal
# minimal-security-severity:Critical =  --sec-severity=Critical update-minimal
update_cmd = default

# Whether a message should be emitted when updates are available,
# were downloaded, or applied.
update_messages = yes

# Whether updates should be downloaded when they are available.
download_updates = yes

# Whether updates should be applied when they are available.  Note
# that download_updates must also be yes for the update to be applied.
apply_updates = yes

# Maximum amout of time to randomly sleep, in minutes.  The program
# will sleep for a random amount of time between 0 and random_sleep
# minutes before running.  This is useful for e.g. staggering the
# times that multiple systems will access update servers.  If
# random_sleep is 0 or negative, the program will run immediately.
# 6*60 = 360
random_sleep = 30
```

I commenti nel file di configurazione parlano da soli.

Ora è possibile abilitare il servizio e avviarlo:

```
$ sudo systemctl enable --now yum-cron
```

## Conclusione

L'aggiornamento automatico dei pacchetti è facilmente attivabile e aumenta notevolmente la sicurezza del vostro sistema informatico.
