---
title: nload - Statistiche sulla larghezza di banda
author: Neel Chauhan
contributors: Spencer Steven
date: 2024-01-16
---

# Introduzione `nload`

`nload` è un monitor del traffico di rete basato su una console di testo. Mostra le statistiche sul traffico e sulla larghezza di banda del vostro server.

## Utilizzare `nload`

```bash
dnf -y install epel-release
dnf -y install nload
```

Seguono le opzioni comuni del comando `nload` che, in circostanze normali, non richiedono nulla di aggiuntivo. Le opzioni precedono l'interfaccia da monitorare:

| Opzioni       | Descrizione                                                                                          |
| ------------- | ---------------------------------------------------------------------------------------------------- |
| -a PERIODO    | Lunghezza della finestra temporale di calcolo in secondi (default: 300)           |
| -m            | Mostra più dispositivi e non mostra il grafico del traffico                                          |
| -t INTERVALLO | Intervallo di aggiornamento in millisecondi (valore predefinito: 500)             |
| -u UNITA'     | Unità di una lettera per la visualizzazione della larghezza di banda (default: k) |
| -U UNITA'     | Unità di una lettera per la visualizzazione del trasferimento dati (default: M)   |

Le unità per queste due ultime opzioni sono le seguenti:

| Unità | Significato |
| ----- | ----------- |
| b     | bit         |
| B     | byte        |
| k     | kilobit     |
| K     | kilobyte    |
| m     | megabit     |
| M     | megabyte    |
| g     | gigabit     |
| G     | gigabyte    |

Un esempio di output dal server domestico dell'autore che esegue un programma [Tor](https://www.torproject.org/) [relay](https://community.torproject.org/relay/types-of-relays/):

```bash
Device bridge0 [172.20.0.3] (1/8):
================================================================================
Incoming:
                                             ########
                                             ########
                                             ########
                                             ########
                                             ########
                                             ########  Curr: 79.13 MBit/s
                                             ########  Avg: 84.99 MBit/s
                                             ########  Min: 79.13 MBit/s
                                             ########  Max: 87.81 MBit/s
                                             ########  Ttl: 1732.95 GByte
Outgoing:
                                             ########
                                             ########
                                             ########
                                             ########
                                             ########
                                             ########  Curr: 81.30 MBit/s
                                             ########  Avg: 88.05 MBit/s
                                             ########  Min: 81.30 MBit/s
                                             ########  Max: 91.36 MBit/s
                                             ########  Ttl: 1790.74 GByte
```

Scomponendo le righe precedenti:

- Curr - utilizzo attuale della larghezza di banda misurata
- Avg - utilizzo medio della larghezza di banda nel periodo
- Min - utilizzo minimo della larghezza di banda misurata
- Max - utilizzo massimo della larghezza di banda misurata
- Ttl - dati trasferiti nella sessione \`nload

## Tasti di scelta rapida per l'interazione

- \++page-down++, ++down++ - Scendere di un'interfaccia
- \++page-up++, ++up++ - Salire di un'interfaccia
- \++f2++ - Mostra la finestra delle opzioni
- \++f5++ - Salva le opzioni
- \++f6++ - Ricaricare le impostazioni dal file di configurazione
- \++q++, ++ctrl+c++ - Chiude `nload`
