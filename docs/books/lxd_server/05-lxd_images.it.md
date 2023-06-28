---
title: 5 Impostazione e gestione delle immagini
author: Steven Spencer
contributors: Ezequiel Bruni, Franco Colussi
tested_with: 8.8, 9.2
tags:
  - lxd
  - enterprise
  - immagini lxd
---

# Capitolo 5: Configurazione e gestione delle immagini

In questo capitolo dovrete eseguire i comandi come utente non privilegiato ("lxdadmin" se avete seguito questo libro dall'inizio).

## Elenco delle immagini disponibili

Probabilmente non vedete l'ora di iniziare con un contenitore. Esistono molte possibilità di sistemi operativi per container. Per avere un'idea del numero di possibilità, inserite questo comando:

```
lxc image list images: | more
```

Digitare la barra spaziatrice per sfogliare l'elenco. Questo elenco di container e macchine virtuali continua a crescere.

L'**ultima** cosa che si vuole fare è cercare un'immagine del contenitore da installare, soprattutto se si conosce l'immagine che si vuole creare. Modificare il comando per mostrare solo le opzioni di installazione di Rocky Linux:

```
lxc image list images: | grep rocky
```

In questo modo si ottiene un elenco molto più gestibile:

```
| rockylinux/8 (3 more)                    | 0ed2f148f7c6 | yes    | Rockylinux 8 amd64 (20220805_02:06)          | x86_64       | CONTAINER       | 128.68MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/8 (3 more)                    | 6411a033fdf1 | yes    | Rockylinux 8 amd64 (20220805_02:06)          | x86_64       | VIRTUAL-MACHINE | 643.15MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/8/arm64 (1 more)              | e677777306cf | yes    | Rockylinux 8 arm64 (20220805_02:29)          | aarch64      | CONTAINER       | 124.06MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/8/cloud (1 more)              | 3d2fe303afd3 | yes    | Rockylinux 8 amd64 (20220805_02:06)          | x86_64       | CONTAINER       | 147.04MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/8/cloud (1 more)              | 7b37619bf333 | yes    | Rockylinux 8 amd64 (20220805_02:06)          | x86_64       | VIRTUAL-MACHINE | 659.58MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/8/cloud/arm64                 | 21c930b2ce7d | yes    | Rockylinux 8 arm64 (20220805_02:06)          | aarch64      | CONTAINER       | 143.17MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/9 (3 more)                    | 61b0171b7eca | yes    | Rockylinux 9 amd64 (20220805_02:07)          | x86_64       | VIRTUAL-MACHINE | 526.38MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/9 (3 more)                    | e7738a0e2923 | yes    | Rockylinux 9 amd64 (20220805_02:07)          | x86_64       | CONTAINER       | 107.80MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/9/arm64 (1 more)              | 917b92a54032 | yes    | Rockylinux 9 arm64 (20220805_02:06)          | aarch64      | CONTAINER       | 103.81MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/9/cloud (1 more)              | 16d3f18f2abb | yes    | Rockylinux 9 amd64 (20220805_02:06)          | x86_64       | CONTAINER       | 123.52MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/9/cloud (1 more)              | 605eadf1c512 | yes    | Rockylinux 9 amd64 (20220805_02:06)          | x86_64       | VIRTUAL-MACHINE | 547.39MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/9/cloud/arm64                 | db3ce70718e3 | yes    | Rockylinux 9 arm64 (20220805_02:06)          | aarch64      | CONTAINER       | 119.27MB  | Aug 5, 2022 at 12:00am (UTC)  |
```

## Installare, rinominare ed elencare le immagini

Per il primo contenitore, si utilizzerà "rockylinux/8". Per installarlo, *si può* usare:

```
lxc launch images:rockylinux/8 rockylinux-test-8
```

Questo creerà un contenitore basato su Rocky Linux chiamato "rockylinux-test-8". È possibile rinominare un contenitore dopo averlo creato, ma prima è necessario arrestare il contenitore, che si avvia automaticamente alla sua creazione.

Per avviare manualmente il container, utilizzare:

```
lxc start rockylinux-test-8
```

Per rinominare l'immagine (non lo faremo qui, ma ecco come farlo), prima di tutto fermate il contenitore:

```
lxc stop rockylinux-test-8
```

Usare il comando `move` per cambiare il nome del contenitore:

```
lxc move rockylinux-test-8 rockylinux-8
```

Se avete seguito comunque questa istruzione, fermate il contenitore e riportatelo al nome originale per continuare a seguirlo.

Ai fini di questa guida, per ora installate altre due immagini:

```
lxc launch images:rockylinux/9 rockylinux-test-9
```

e

```
lxc launch images:ubuntu/22.04 ubuntu-test
```

Esaminate ciò che avete elencando le vostre immagini:

```
lxc list
```

che restituirà questo:

```
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

