---
title: Inizializzazione e configurazione utente di 3 LXD
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.8, 9.2
tags:
  - lxd
  - enterprise
  - lxd initialization
  - lxd setup
---

# Capitolo 3: Inizializzazione di LXD e configurazione dell'utente

In questo capitolo è necessario essere root o poter fare `sudo` per diventare root. Inoltre, si presuppone che sia stato configurato un pool di archiviazione ZFS, come descritto nel [Capitolo 2](02-zfs_setup.md). È possibile utilizzare un pool di archiviazione diverso se si è scelto di non utilizzare ZFS, ma sarà necessario apportare modifiche alle domande e alle risposte di inizializzazione.

## Inizializzazione di LXD

L'ambiente del server è pronto. Si è pronti a inizializzare LXD. Si tratta di uno script automatico che pone una serie di domande per rendere operativa l'istanza LXD:

```
lxd init
```

Ecco le domande e le nostre risposte per lo script, con una piccola spiegazione dove necessario:

```
Would you like to use LXD clustering? (yes/no) [default=no]:
```

Se siete interessati al clustering, fate ulteriori ricerche in merito [qui](https://linuxcontainers.org/lxd/docs/master/clustering/)

```
Do you want to configure a new storage pool? (yes/no) [default=yes]:
```

Questo sembra controintuitivo. Il pool ZFS è già stato creato, ma sarà chiaro in una domanda successiva. Accettare l'impostazione predefinita.

```
Name of the new storage pool [default=default]: storage
```

Lasciare questo nome "default" è un'opzione, ma per chiarezza è meglio usare lo stesso nome dato al pool ZFS.

```
Name of the storage backend to use (btrfs, dir, lvm, zfs, ceph) [default=zfs]:
```

You want to accept the default.

```
Create a new ZFS pool? (yes/no) [default=yes]: no
```

È qui che entra in gioco la risoluzione della domanda precedente sulla creazione di un pool di storage.

```
Name of the existing ZFS pool or dataset: storage
Would you like to connect to a MAAS server? (yes/no) [default=no]:
```

Il Metal As A Service (MAAS) non rientra nell'ambito di questo documento.

```
Would you like to create a new local network bridge? (yes/no) [default=yes]:
What should the new bridge be called? [default=lxdbr0]: 
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: none
```

Se si desidera utilizzare IPv6 sui propri contenitori LXD, è possibile attivare questa opzione. Questo dipende da voi.

```
Would you like the LXD server to be available over the network? (yes/no) [default=no]: yes
```

È necessario per eseguire lo snapshot del server.

```
Address to bind LXD to (not including port) [default=all]:
Port to bind LXD to [default=8443]:
Trust password for new clients:
Again:
```

Questa password di fiducia è il modo in cui ci si connette al server snapshot o si torna indietro dal server snapshot. Impostate qualcosa che abbia senso nel vostro ambiente. Salvare questa voce in un luogo sicuro, ad esempio in un gestore di password.

```
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]:
```

## Impostazione dei privilegi degli utenti

Prima di continuare, è necessario creare l'utente "lxdadmin" e assicurarsi che abbia i privilegi necessari. È necessario che l'utente "lxdadmin" sia in grado di eseguire il `sudo` a root e che sia membro del gruppo lxd. Per aggiungere l'utente e assicurarsi che sia membro di entrambi i gruppi, procedere come segue:

```
useradd -G wheel,lxd lxdadmin
```

Impostare la password:

```
passwd lxdadmin
```

Come per le altre password, salvatela in un luogo sicuro.
