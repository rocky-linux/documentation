---
title: 3 Inizializzazione Incus e configurazione dell'utente
author: Spencer Steven
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - enterprise
  - incus initialization
  - incus setup
---

Nel corso di questo capitolo, è necessario essere l'utente root o essere in grado di eseguire con i privilegi di root con sudo. Inoltre, si presume che sia stato configurato un pool di archiviazione ZFS come descritto nel [Capitolo 2](02-zfs_setup.md). Se si è scelto di non utilizzare ZFS, è possibile utilizzare un pool di archiviazione diverso, ma sarà necessario modificare le domande e le risposte di inizializzazione.

## Inizializzazione di Incus

L'ambiente del server è pronto. È ora possibile inizializzare Incus. Si tratta di uno script automatico che pone una serie di domande per rendere operativa la vostra istanza di Incus:

```bash
incus admin init
```

Ecco le domande e le nostre risposte per lo script, con una piccola spiegazione dove necessario:

```text
Would you like to use clustering? (yes/no) [default=no]:
```

Se si è interessati al clustering, è consigliato fare ulteriori ricerche al riguardo [qui](https://linuxcontainers.org/incus/docs/main/explanation/clustering/)

```text
Do you want to configure a new storage pool? (yes/no) [default=yes]:
```

Questo sembra controintuitivo. Il pool ZFS è già stato creato, ma sarà chiaro in una domanda successiva. Accettare l'impostazione predefinita.

```text
Name of the new storage pool [default=default]: storage
```

Lasciare questo nome “default” è un'opzione, ma usare lo stesso nome dato al pool ZFS è preferibile per chiarezza.

```text
Name of the storage backend to use (btrfs, dir, lvm, zfs, ceph) [default=zfs]:
```

You want to accept the default.

```text
Create a new ZFS pool? (yes/no) [default=yes]: no
```

È qui che entra in gioco la risoluzione della domanda precedente sulla creazione di un pool di storage.

```text
Name of the existing ZFS pool or dataset: storage
Would you like to connect to a MAAS server? (yes/no) [default=no]:
```

Il Metal As A Service (MAAS) non rientra nell'ambito di questo documento.

```text
Would you like to create a new local network bridge? (yes/no) [default=yes]:
What should the new bridge be called? [default=incusbr0]: 
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: none
```

È possibile attivare questa opzione per utilizzare IPv6 sui contenitori Incus.

```text
Would you like the Incus server to be available over the network? (yes/no) [default=no]: yes
```

È necessario per eseguire lo snapshot del server.

```text
Address to bind Incus to (not including port) [default=all]:
Port to bind Incus to [default=8443]:
Trust password for new clients:
Again:
```

Questa trust password è il modo in cui ci si connette o si torna indietro dal server snapshot. Impostatela con qualcosa che abbia senso nel vostro ambiente. Salvare questa voce in un luogo sicuro, ad esempio in un gestore di password.

```text
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]
Would you like a YAML "incus admin init" preseed to be printed? (yes/no) [default=no]:
```

## Impostazione dei privilegi degli utenti

Prima di continuare, è necessario creare l'utente “incusadmin” e assicurarsi che abbia i privilegi necessari. È necessario che l'utente “incusadmin” sia in grado di fare `sudo` a root e che sia membro del gruppo `incus-admin`. Per aggiungere l'utente e assicurarsi che sia membro di entrambi i gruppi, procedere come segue:

```bash
useradd -G wheel,incus-admin incusadmin
```

Impostare la password:

```bash
passwd incusadmin
```

Come per le altre password, salvatela in un luogo sicuro.

## Impostazione dei valori `subuid` e `subgid` per `root`

È necessario impostare sia il valore del `subuid` che del `subgid` dell'utente root (l'intervallo di ID degli utenti e dei gruppi subordinati). I parametri dovrebbero essere:

```bash
root:1000000:1000000000
```

Per farlo, modificare `/etc/subuid` e aggiungere questa riga. Quando completo, il file dovrebbe essere:

```bash
root:1000000:1000000000
```

Modificare il file `/etc/subgid` e aggiungere questa riga. Quando completo, il file dovrebbe essere:

```bash
incusadmin:100000:65536
root:1000000:1000000000
```

Riavviare il server prima di continuare.
