---
title: 5 Impostazione e gestione delle immagini
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - enterprise
  - incus images
---

In questo capitolo, i comandi devono essere eseguiti come utente non privilegiato (“incusadmin” se avete seguito questo libro dall'inizio).

## Elenco delle immagini disponibili

Probabilmente non vedete l'ora di iniziare con un contenitore. Esistono molte possibilità di sistemi operativi per container. Per avere un'idea del numero di possibilità, inserite questo comando:

```bash
incus image list images: | more
```

Digitare la barra spaziatrice per sfogliare l'elenco. Questo elenco di container e macchine virtuali continua a crescere.

Come **ultima** cosa che si vuole fare è cercare un'immagine del contenitore da installare, soprattutto se si conosce l'immagine che si vuole creare. Modificare il comando per mostrare solo le opzioni di installazione di Rocky Linux:

```bash
incus image list images: | grep rocky
```

In questo modo si ottiene un elenco molto più gestibile:

```bash
| rockylinux/8 (3 more)                    | dede6169bb45 | yes    | Rockylinux 8 amd64 (20240903_05:18)        | x86_64       | VIRTUAL-MACHINE | 850.75MiB  | 2024/09/02 19:00 CDT |
| rockylinux/8/arm64 (1 more)              | b749bad83e60 | yes    | Rockylinux 8 arm64 (20240903_04:40)        | aarch64      | CONTAINER       | 125.51MiB  | 2024/09/02 19:00 CDT |
| rockylinux/8/cloud (1 more)              | 4fefd464d25d | yes    | Rockylinux 8 amd64 (20240903_05:18)        | x86_64       | VIRTUAL-MACHINE | 869.95MiB  | 2024/09/02 19:00 CDT |
| rockylinux/8/cloud (1 more)              | 729891475172 | yes    | Rockylinux 8 amd64 (20240903_05:18)        | x86_64       | CONTAINER       | 148.81MiB  | 2024/09/02 19:00 CDT |
| rockylinux/8/cloud/arm64                 | 3642ec9652fc | yes    | Rockylinux 8 arm64 (20240903_04:52)        | aarch64      | CONTAINER       | 144.84MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9 (3 more)                    | 9e5e4469e660 | yes    | Rockylinux 9 amd64 (20240903_03:29)        | x86_64       | VIRTUAL-MACHINE | 728.60MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9 (3 more)                    | fff1706d5834 | yes    | Rockylinux 9 amd64 (20240903_03:29)        | x86_64       | CONTAINER       | 111.25MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9/arm64 (1 more)              | d3a44df90d69 | yes    | Rockylinux 9 arm64 (20240903_04:49)        | aarch64      | CONTAINER       | 107.18MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9/cloud (1 more)              | 4329a67099ba | yes    | Rockylinux 9 amd64 (20240903_03:28)        | x86_64       | VIRTUAL-MACHINE | 749.29MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9/cloud (1 more)              | bc30d585b9f0 | yes    | Rockylinux 9 amd64 (20240903_03:28)        | x86_64       | CONTAINER       | 127.16MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9/cloud/arm64                 | 5c38ddd506bd | yes    | Rockylinux 9 arm64 (20240903_04:38)        | aarch64      | CONTAINER       | 122.87MiB  | 2024/09/02 19:00 CDT |
```

## Installare, rinominare ed elencare le immagini

Per il primo contenitore, si utilizzerà "rockylinux/8". Per installarlo, si può usare:

```bash
incus launch images:rockylinux/8 rockylinux-test-8
```

Questo creerà un contenitore basato su Rocky Linux chiamato "rockylinux-test-8". È possibile rinominare un contenitore dopo averlo creato, ma prima è necessario arrestare il contenitore, che si avvia automaticamente alla sua creazione.

Per avviare manualmente il container, utilizzare:

```bash
incus start rockylinux-test-8
```

Per rinominare l'immagine (non lo si vedrà ora, ma mostriamo come farlo), prima di tutto arrestare il container:

```bash
incus stop rockylinux-test-8
```

Usare il comando `move` per cambiare il nome del container:

```bash
incus move rockylinux-test-8 rockylinux-8
```

Se avete comunque seguito queste istruzioni, fermate il contenitore e riportatelo al nome originale per continuare a seguire la procedura.

Per questa guida, per ora installare altre due immagini:

```bash
incus launch images:rockylinux/9 rockylinux-test-9
```

e

```bash
incus launch images:ubuntu/22.04 ubuntu-test
```

Esaminate ciò che avete elencando le vostre immagini:

```bash
incus list
```

che restituirà questo:

```bash
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 10.146.84.179 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 10.146.84.180 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 10.146.84.181 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
```
