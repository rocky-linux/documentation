---
title: 2 ZFS Setup
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - enterprise
  - incus zfs
---

# Capitolo 2: Configurazione di ZFS

In tutti i passaggi di questo capitolo, è necessario essere l'utente root o poter eseguire i comandi come root utilizzando `sudo` .

Se avete già installato ZFS, questa sezione vi guiderà attraverso la configurazione di ZFS.

## Abilitazione di ZFS e impostazione del pool

Per prima cosa, inserite questo comando:

```bash
/sbin/modprobe zfs
```

Se non ci sono errori, si ritorna al prompt e non viene emesso alcun eco. Se si verifica un errore, è possibile fermarsi ora e iniziare il troubleshooting. Anche in questo caso, assicuratevi che il secure boot sia disattivato. Questo sarà il colpevole più probabile.

Successivamente, è necessario esaminare i dischi del sistema, scoprire dove si trova il sistema operativo e determinare cosa è disponibile per il pool ZFS. Questo si fa con `lsblk`:

```bash
lsblk
```

Che restituirà qualcosa di simile (il vostro sistema sarà diverso!):

```bash
AME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
loop0    7:0    0  32.3M  1 loop /var/lib/snapd/snap/snapd/11588
loop1    7:1    0  55.5M  1 loop /var/lib/snapd/snap/core18/1997
loop2    7:2    0  68.8M  1 loop /var/lib/snapd/snap/lxd/20037
sda      8:0    0 119.2G  0 disk
├─sda1   8:1    0   600M  0 part /boot/efi
├─sda2   8:2    0     1G  0 part /boot
├─sda3   8:3    0  11.9G  0 part [SWAP]
├─sda4   8:4    0     2G  0 part /home
└─sda5   8:5    0 103.7G  0 part /
sdb      8:16   0 119.2G  0 disk
├─sdb1   8:17   0 119.2G  0 part
└─sdb9   8:25   0     8M  0 part
sdc      8:32   0 149.1G  0 disk
└─sdc1   8:33   0 149.1G  0 part
```

Questo elenco mostra che il sistema operativo utilizza _/dev/sda_. Si utilizzerà _/dev/sdb_ per zpool. Si noti che se si dispone di molti dischi rigidi, si può prendere in considerazione l'uso di raidz (un software raid specifico per ZFS).

Ciò esula dall'ambito di questa documentazione, ma è una considerazione per la produzione. Offre migliori prestazioni e ridondanza. Per ora, create il vostro pool sul singolo dispositivo che avete identificato:

```bash
zpool create storage /dev/sdb
```

Questo dice di creare un pool chiamato “storage” che è ZFS sul dispositivo _/dev/sdb_.

Dopo aver creato il pool, riavviare il server.
