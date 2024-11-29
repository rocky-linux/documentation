---
title: 10 Automatizzare
author: Spencer Steven
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - enterprise
  - incus automation
---

Nel corso di questo capitolo, è necessario essere l'utente root o essere in grado di eseguire con i privilegi di root con sudo.

L'automazione del processo di snapshot rende le cose molto più facili.

## Automatizzazione del Processo di Copia di Istantanee

Eseguire questa procedura su incus-primary. La prima cosa da fare è creare uno script che verrà eseguito da cron in /usr/local/sbin chiamato "refresh-containers" :

```bash
sudo vi /usr/local/sbin/refreshcontainers.sh
```

Lo script è piuttosto semplice:

```bash
#!/bin/bash
# This script is for doing an lxc copy --refresh against each container, copying
# and updating them to the snapshot server.

for x in $(/var/lib/snapd/snap/bin/lxc ls -c n --format csv)
        do echo "Refreshing $x"
        /var/lib/snapd/snap/bin/lxc copy --refresh $x incus-snapshot:$x
        done

```

E poi renderlo eseguibile:

```bash
sudo chmod +x /usr/local/sbin/refreshcontainers.sh
```

Cambiare la ownership di questo script all'utente e al gruppo incusadmin:

```bash
sudo chown incusadmin.incusadmin /usr/local/sbin/refreshcontainers.sh
```

Impostare il crontab per l'utente incusadmin per l'esecuzione di questo script, in questo caso alle 10 di sera:

```bash
crontab -e
```

La voce avrà il seguente aspetto:

```bash
00 22 * * * /usr/local/sbin/refreshcontainers.sh > /home/incusadmin/refreshlog 2>&1
```

Salvare le modifiche e uscire.

Questo creerà un log, nella home directory di incusadmin, chiamato “refreshlog”, che permetterà di sapere se il processo ha funzionato o meno. Molto importante!

La procedura automatica a volte fallisce. Questo accade generalmente quando un particolare container non riesce ad aggiornarsi. È possibile eseguire manualmente l'aggiornamento con il seguente comando (assumendo rockylinux-test-9 qui, come nostro contenitore):

```bash
lxc copy --refresh rockylinux-test-9 incus-snapshot:rockylinux-test-9
```
