---
title: htop - Gestione dei Processi
author: tianci li
contributors: Steven Spencer, Franco Colussi
date: 2021-10-16
tags:
  - htop
  - processes
---

# htop - Gestione dei processi

## installare `htop`
Ogni amministratore di sistema ama utilizzare alcuni dei comandi più comuni. Oggi raccomando `htop` come alternativa al comando `top`. Per utilizzare normalmente il comando `htop`, è necessario prima installarlo.

``` bash
# Installation epel source (also called repository)
dnf -y install epel-release
# Generate cache
dnf makecache
# Install htop
dnf -y install htop
```

## Utilizzare `htop`
È sufficiente digitare `htop` nel terminale e l'interfaccia interattiva è la seguente:

```
0[ |||                      3%]     Tasks: 24, 14thr; 1 running
1[ |                        1%]     Load average: 0.00 0.00 0.05
Mem[ |||||||           197M/8G]     Uptime: 00:31:39
Swap[                  0K/500M]
PID   USER   PRI   NI   VIRT   RES   SHR   S   CPU%   MEM%   TIME+   Command(merged)
...
```

<kbd>F1</kbd>Help   <kbd>F2</kbd>Setup  <kbd>F3</kbd>Search <kbd>F4</kbd>Filter <kbd>F5</kbd>Tree   <kbd>F6</kbd>SortBy <kbd>F7</kbd>Nice   <kbd>F8</kbd>Nice+  <kbd>F9</kbd>Kill   <kbd>F10</kbd>Quit

### Descrizione Superiore

* I numeri 0 e 1 in alto indicano il numero di core della CPU, mentre la percentuale indica il tasso di occupazione di un singolo core (naturalmente è possibile visualizzare anche il tasso di occupazione totale della CPU)
    * I diversi colori della barra di avanzamento indicano la percentuale dei diversi tipi di processo:

        | Colore    | Osservazioni                                                       |
        | --------- | ------------------------------------------------------------------ |
        | Blu       | Percentuale di CPU utilizzata da processi a bassa priorità         |
        | Verde     | Percentuale della CPU del processo posseduta dagli utenti ordinari |
        | Rosso     | Percentuale di CPU utilizzata dai processi di sistema              |
        | Arancione | Percentuale della CPU utilizzata dai IRQ time                      |
        | Magenta   | Percentuale della CPU utilizzata dal soft IRQ time                 |
        | Grigio    | Percentuale di CPU occupata dal tempo di attesa IO                 |
        | Ciano     | Percentuale di CPU consumata dallo Steal time                      |

* Tasks: 24, 14thr; 1 running, process information. Nel mio esempio, significa che la mia macchina attuale ha 24 task, suddivisi in 14 thread, di cui solo 1 processo è in esecuzione.
* Informazioni sulla memoria e sullo swap. Allo stesso modo, utilizza colori diversi per distinguerli:

 | Colore    | Osservazioni                                           |
 | --------- | ------------------------------------------------------ |
 | Blu       | Percentuale di memoria consumata dal buffer            |
 | Verde     | Percentuale di memoria consumata dall'area di memoria  |
 | Arancione | Percentuale di memoria consumata dall'area della cache |

* Carico medio, i tre valori rappresentano rispettivamente il carico medio del sistema negli ultimi 1 minuto, negli ultimi 5 minuti e negli ultimi 15 minuti
* Uptime, ossia il tempo di funzionamento dopo l'avvio

### Descrizione delle informazioni sul processo

* **PID-Numero ID del processo**

* USER: il proprietario del processo
* PRI: visualizza la priorità del processo vista dal kernel Linux
* NI- mostra la priorità del processo di reset da parte dell'utente normale o del superutente root
* VIRI-memoria virtuale consumata da un processo

* **RES-Memoria fisica consumata da un processo**

* Memoria condivisa SHR consumata da un processo
* S - Lo stato attuale del processo, c'è uno stato speciale a cui prestare attenzione! Questo è Z (processo zombie). Se nella macchina è presente un numero elevato di processi zombie, le prestazioni della macchina ne risentono.

* **CPU%-Percentuale di CPU consumata da ciascun processo**

* MEM%-Percentuale di memoria consumata da ciascun processo
* TIME+-mostra il tempo di esecuzione dall'avvio del processo
* Command-il comando corrispondente al processo

### Descrizione del tasto di scelta rapida
Nell'interfaccia interattiva, premere il tasto <kbd>F1</kbd> per visualizzare la descrizione del tasto di scelta rapida corrispondente.

* I tasti direzionali su, giù, sinistra e destra consentono di scorrere l'interfaccia interattiva e lo <kbd>spazio</kbd> può contrassegnare il processo corrispondente, contrassegnato in giallo.
* I pulsanti <kbd>N</kbd>, <kbd>P</kbd>, <kbd>M</kbd> e <kbd>T</kbd> indicano rispettivamente PID, CPU%, MEM%, TIME+ e sono usati per l'ordinamento. Naturalmente, è anche possibile fare clic con il mouse per ordinare in ordine crescente o decrescente un determinato campo.

### Altri strumenti comunemente utilizzati
Per gestire il processo, utilizzare il tasto <kbd>F9</kbd> per inviare diversi segnali al processo. L'elenco dei segnali si trova in `kill -l`. Quelli più comunemente utilizzati sono:

| Segnale | Osservazioni                                                                                                                                                                                        |
| ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1       | Lasciare che il processo si chiuda immediatamente e poi riavviarlo dopo aver riletto il file di configurazione                                                                                      |
| 9       | Usato per terminare immediatamente l'esecuzione del programma, usato per terminare forzatamente il processo, simile alla fine forzata nella barra delle applicazioni di Windows                     |
| 15      | Il segnale predefinito per il comando kill. A volte, se si è verificato un problema nel processo e il processo non può essere terminato normalmente con questo segnale, si proverà con il segnale 9 |

## Fine
`htop` è molto più facile da usare rispetto al `top` fornito con il sistema, è più intuitivo e migliora notevolmente l'uso quotidiano. Per questo motivo, di solito l'autore lo installa per primo dopo aver installato il sistema operativo.
