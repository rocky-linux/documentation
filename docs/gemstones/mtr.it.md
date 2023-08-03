---
title: mtr - Diagnostica di rete
author: tianci li
contributors: Steven Spencer, Franco Colussi
date: 2022-02-13
---

# `mtr` Introduzione

`mtr` è uno strumento di diagnostica di rete in grado di diagnosticare i problemi della rete. Viene utilizzato per sostituire i comandi `ping` e `traceroute`. In termini di prestazioni, il comando `mtr` è più veloce.

## Utilizzare `mtr`

```bash
# Install mtr
shell > dnf -y install mtr
```

Le opzioni comuni del comando `mtr` sono le seguenti. In circostanze normali, non sono richieste opzioni aggiuntive, seguite direttamente dal nome host o dall'indirizzo IP:

| Opzioni  | Descrizione                           |
| -------- | ------------------------------------- |
| -4       | # Usa solo IPv4                      |
| -6       | # Usa solo IPv6                      |
| -c COUNT | # Numero di ping inviati             |
| -n       | # Non risolvere il nome dell'host    |
| -z       | # Visualizzazione del numero di AS   |
| -b       | # Visualizzare ip e hostname         |
| -w       | # Output di un'ampia gamma di report |

Le informazioni scambiate dal terminale sono le seguenti:

```bash
shell > mtr -c 10 bing.com
 My traceroutr [v0.92]
li(192.168.100.4) 2021-10-20T08:02:05+0800
Keys:Help Display mode Restart Statistics Order of fields quit
HOST: li Loss% Snt Last Avg Best Wrst StDev
 1. _gateway 0.0% 10 2.0 5.6 2.0 12.9 3.6
 2. 10.9.128.1 0.0% 10 13.9 14.8 8.5 20.7 3.9
 3. 120.80.175.109 0.0% 10 15.8 15.0 10.0 20.1 3.1
 4. 112.89.0.57 20.0% 10 18.9 15.2 11.5 18.9 2.9
 5.219.158.8.114 0.0% 10 10.8 14.4 10.6 20.5 3.5
 6. 219.158.24.134 0.0% 10 13.1 14.5 11.9 18.9 2.2
 7. 219.158.10.30 0.0% 10 14.9 21.2 12.0 29.8 6.9
 8. 219.158.33.114 0.0% 10 17.7 17.1 13.0 20.0 2.0
 9. ??? 100.0 10 0.0 0.0 0.0 0.0 0.0
10. ??? 100.0 10 0.0 0.0 0.0 0.0 0.0
11. ??? 100.0 10 0.0 0.0 0.0 0.0 0.0
12. ??? 100.0 10 0.0 0.0 0.0 0.0 0.0
13. a-0001.a-msedge.net 0.0% 10 18.4 15.7 9.5 19.3 3.1
...
```

* Loss% - tasso di perdita del pacchetto
* Snt - il numero di pacchetti inviati
* Last- il ritardo dell'ultimo pacchetto
* Avg - ritardo medio
* Best: la latenza più bassa
* Wrst - Ritardo peggiore
* StDev - varianza (stabilità)

## Tasti di scelta rapida per l'interazione
<kbd>p</kbd> - pausa; <kbd>d</kbd> - cambia modalità di visualizzazione; <kbd>n</kbd> - attiva/disattiva il DNS; <kbd>r</kbd> - azzera tutti i contatori; <kbd>j</kbd> - alterna le informazioni di visualizzazione del ritardo; <kbd>y</kbd> - cambia le informazioni IP; <kbd>q</kbd> - Esce dall'interazione.
