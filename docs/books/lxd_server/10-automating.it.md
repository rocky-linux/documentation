---
title: 10 Automatizzare
author: Steven Spencer, Franco Colussi
contributors: Ezequiel Bruni, Franco Colussi
tested_with: 8.8, 9.2
tags:
  - lxd
  - enterprise
  - automazione lxd
---

# Capitolo 10: Automatizzare

Durante tutto questo capitolo dovrai essere radice o in grado di `sudo` per diventare root.

L'automazione del processo di snapshot rende le cose molto più facili.

## Automatizzazione del Processo di Copia di Istantanee


Questo processo viene eseguito su lxd-primario. La prima cosa da fare è creare uno script che verrà eseguito da cron in /usr/local/sbin chiamato "refresh-containers" :

```
sudo vi /usr/local/sbin/refreshcontainers.sh
```

Lo script è piuttosto semplice:

```
#!/bin/bash
# This script is for doing an lxc copy --refresh against each container, copying
# and updating them to the snapshot server.

for x in $(/var/lib/snapd/snap/bin/lxc ls -c n --format csv)
        do echo "Refreshing $x"
        /var/lib/snapd/snap/bin/lxc copy --refresh $x lxd-snapshot:$x
        done

```

 Rendetelo eseguibile:

```
sudo chmod +x /usr/local/sbin/refreshcontainers.sh
```

Cambiare la proprietà di questo script all'utente e al gruppo lxdadmin:

```
sudo chown lxdadmin.lxdadmin /usr/local/sbin/refreshcontainers.sh
```

Impostare il crontab per l'utente lxdadmin per l'esecuzione di questo script, in questo caso alle 10 di sera:

```
crontab -e
```

La voce avrà il seguente aspetto:

```
00 22 * * * /usr/local/sbin/refreshcontainers.sh > /home/lxdadmin/refreshlog 2>&1
```

Salvare le modifiche e uscire.

In questo modo si creerà un registro nella home directory di lxdadmin chiamato "refreshlog" che permetterà di sapere se il processo ha funzionato o meno. Molto importante!

La procedura automatica a volte fallisce. Questo accade generalmente quando un particolare container non riesce ad aggiornarsi. È possibile eseguire manualmente l'aggiornamento con il seguente comando (assumendo rockylinux-test-9 qui, come nostro contenitore):

```
lxc copy --refresh rockylinux-test-9 lxd-snapshot:rockylinux-test-9
```
