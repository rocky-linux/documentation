---
title: iftop - Statistiche in tempo reale sulla larghezza di banda per connessione
author: Neel Chauhan
contributors: Ganna Zhyrnova, Steven Spencer
date: 2024-02-24
---

# Introduzione a `iftop`

`iftop` è un monitor del traffico di rete basato su una console di testo. Visualizza le statistiche sul traffico e sulla larghezza di banda del vostro server per ogni connessione.

## Utilizzare `iftop`

```bash
dnf -y install epel-release
dnf -y install iftop
```

Seguono le opzioni del comando `iftop`.

| Opzioni        | Descrizione                                                                                                      |
| -------------- | ---------------------------------------------------------------------------------------------------------------- |
| -n             | Evita la ricerca del nome dell'host                                                                              |
| -N             | Evita di risolvere i numeri di porta con i nomi dei servizi                                                      |
| -p             | Funziona in modalità promiscua, quindi tutto il traffico viene conteggiato                                       |
| -P             | Visualizza i numeri di porta per le connessioni                                                                  |
| -l             | Visualizza e conteggia il traffico da o verso gli indirizzi IPv6 link-local                                      |
| -b             | Non visualizza i grafici a barre per il traffico                                                                 |
| -m LIMIT       | Imposta un limite superiore per il grafico della larghezza di banda, specificato come numero e suffisso di unità |
| -u UNIT        | Visualizza le velocità del traffico per l'unità di misura indicata                                               |
| -B UNIT        | Sinonimo di -u                                                                                                   |
| -i INTERFACE   | Interfaccia di misura                                                                                            |
| -f FILTER CODE | Utilizza il seguente codice del filtro                                                                           |
| -F NET/MASK    | Misura esclusivamente il traffico diretto alla rete IPv4 specificata                                             |
| -G NET/MASK    | Misura esclusivamente il traffico diretto alla rete IPv6 specificata                                             |
| -c config      | Utilizza il seguente file di configurazione                                                                      |
| -t             | Utilizza la modalità non-ncurses                                                                                 |

Le unità per la flag **-M** sono le seguenti:

| Unità | Significato |
| ----- | ----------- |
| K     | Chilo       |
| M     | Mega        |
| G     | Giga        |

Le unità per la flag **-u** sono le seguenti:

| Unità   | Significato          |
| ------- | -------------------- |
| bit     | bit al secondo       |
| bytes   | byte al secondo      |
| packets | pacchetti al secondo |

Un esempio di output dal server domestico dell'autore che esegue un programma [Tor](https://www.torproject.org/) [relay](https://community.torproject.org/relay/types-of-relays/):

```bash
 Listening on bridge b          25.0Kb          37.5Kb          50.0Kb    62.5Kb
└───────────────┴───────────────┴───────────────┴───────────────┴───────────────
tt.neelc.org               => X.X.X.X                    13.5Mb  13.5Mb  13.5Mb
                           <=                             749Kb   749Kb   749Kb
tt.neelc.org               => X.X.X.X                    6.21Mb  6.21Mb  6.21Mb
                           <=                             317Kb   317Kb   317Kb
tt.neelc.org               => X.X.X.X                    3.61Mb  3.61Mb  3.61Mb
                           <=                             194Kb   194Kb   194Kb
tt.neelc.org               => X.X.X.X                     181Kb   181Kb   181Kb
                           <=                            3.36Mb  3.36Mb  3.36Mb
tt.neelc.org               => X.X.X.X                     151Kb   151Kb   151Kb
                           <=                            3.24Mb  3.24Mb  3.24Mb
tt.neelc.org               => X.X.X.X                    2.97Mb  2.97Mb  2.97Mb
                           <=                             205Kb   205Kb   205Kb
tt.neelc.org               => X.X.X.X                     156Kb   156Kb   156Kb
                           <=                            2.97Mb  2.97Mb  2.97Mb
tt.neelc.org               => X.X.X.X                    2.80Mb  2.80Mb  2.80Mb
                           <=                             145Kb   145Kb   145Kb
tt.neelc.org               => X.X.X.X                     136Kb   136Kb   136Kb
                           <=                            2.45Mb  2.45Mb  2.45Mb
────────────────────────────────────────────────────────────────────────────────
TX:             cum:   30.1MB   peak:    121Mb  rates:    121Mb   121Mb   121Mb
RX:                    30.4MB            122Mb            122Mb   122Mb   122Mb
TOTAL:                 60.5MB            242Mb            242Mb   242Mb   242Mb
```

Sezionando le righe finali del pannello:

- TX - Utilizzo dei dati di trasmissione/caricamento
- RX - Utilizzo dei dati di ricezione/download
- TOTAL - Utilizzo combinato di upload/download

## Tasti di scelta rapida per l'interazione

- \++s++ - aggrega tutto il traffico per ogni origine
- \++d++ - aggrega tutto il traffico per ogni destinazione
- \++shift+s++ - attiva/disattiva la visualizzazione della porta di origine
- \++shift+d++ - attiva/disattiva la visualizzazione della porta di destinazione
- \++t++ - passa da una modalità di visualizzazione all'altra: visualizzazione predefinita a due righe con traffico in invio e in ricezione e visualizzazione a tre righe con traffico in invio, in ricezione e totale
- \++1++, ++2++, ++3++ - ordina per prima, seconda o terza colonna
- \++l++ - inserisce un'espressione regolare POSIX per filtrare i nomi di host
- \++shift+p++ - mette in pausa la visualizzazione corrente
- \++o++ - blocca il conteggio della larghezza di banda totale
- \++j++ - scorre verso il basso
- \++k++ - scorre verso l'alto
- \++f++ - modifica il codice del filtro
