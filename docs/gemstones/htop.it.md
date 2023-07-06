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
0[ |||                      3%]     Tasks: 22, 46thr, 174 kthr 1 running
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

        | Colore    | Osservazioni                                                       | Nomi visualizzati in altri stili |
        | --------- | ------------------------------------------------------------------ | -------------------------------- |
        | Blu       | Percentuale di CPU utilizzata da processi a bassa priorità         | basso                            |
        | Verde     | Percentuale della CPU del processo posseduta dagli utenti ordinari |                                  |
        | Rosso     | Percentuale di CPU utilizzata dai processi di sistema              | sys                              |
        | Arancione | Percentuale della CPU utilizzata da Steal Time                     | vir                              |

* Tasks: 22, 46thr, 174 kthr 1 running. Nel mio esempio, significa che la mia macchina attuale ha 22 task, che sono divisi in 46 thread, di cui solo 1 processo è in stato di esecuzione, "kthr" indica quanti thread del kernel ci sono.
* Informazioni sulla memoria. Allo stesso modo, utilizza colori diversi per distinguerli:

   | Colore           | Osservazioni                                                   | Nomi visualizzati in altri stili |
   | ---------------- | -------------------------------------------------------------- | -------------------------------- |
   | Blu              | Percentuale di memoria consumata dal buffer                    | buffers                          |
   | Verde            | Percentuale di memoria consumata dall'area di memoria          | usata                            |
   | Giallo/Arancione | Percentuale di memoria consumata dall'area della cache         | cache                            |
   | Magenta          | Percentuale di memoria occupata dall'area di memoria condivisa | condivisa                        |

* Informazioni sulla Swap.

   | Colore           | Osservazioni                                        | Nomi visualizzati in altri stili |
   | ---------------- | --------------------------------------------------- | -------------------------------- |
   | Verde            | Percentuale di swap consumata dall'area di swap     | usata                            |
   | Giallo/Arancione | Percentuale di swap consumata dall'area della cache | cache                            |

* Carico medio, i tre valori rappresentano rispettivamente il carico medio del sistema negli ultimi 1 minuto, negli ultimi 5 minuti e negli ultimi 15 minuti
* Uptime, ossia il tempo di funzionamento dopo l'avvio

### Descrizione delle informazioni sul processo

* **PID - Numero ID del processo**
* USER - Il proprietario del processo
* PRI - Visualizza la priorità del processo vista dal kernel Linux
* NI - Visualizza la priorità del processo di reset da parte dell'utente normale o del superutente root
* VIRT - Memoria virtuale consumata da un processo
* **RES - Memoria fisica consumata da un processo**
* SHR - Memoria condivisa consumata da un processo
* S - Lo stato attuale del processo, c'è uno stato speciale a cui prestare attenzione! Questo è Z (processo zombie). Se nella macchina è presente un numero elevato di processi zombie, le prestazioni della macchina ne risentono.
* **CPU% - Percentuale di CPU consumata da ciascun processo**
* CPU% - Percentuale di CPU consumata da ciascun processo
* TIME+ - Mostra il tempo di esecuzione dall'avvio del processo
* Command - Il comando corrispondente al processo

### Descrizione del tasto di scelta rapida
Nell'interfaccia interattiva, premere il tasto <kbd>F1</kbd> per visualizzare la descrizione del tasto di scelta rapida corrispondente.

* I tasti direzionali su, giù, sinistra e destra consentono di scorrere l'interfaccia interattiva e <kbd>spazio</kbd> può contrassegnare il processo corrispondente, che è contrassegnato in giallo.
* I pulsanti <kbd>N</kbd>, <kbd>P</kbd>, <kbd>M</kbd> e <kbd>T</kbd> indicano rispettivamente PID, CPU%, MEM%, TIME+ e sono usati per l'ordinamento. Naturalmente, è anche possibile fare clic con il mouse per ordinare in ordine crescente o decrescente un determinato campo.

### Altri strumenti comunemente utilizzati
Per gestire il processo, utilizzare il tasto <kbd>F9</kbd> per inviare diversi segnali al processo. L'elenco dei segnali si trova in `kill -l`. Quelli più comunemente utilizzati sono:

| Segnale | Descrizione                                                                                                                                                                                         |
| ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1       | Permette al processo di chiudersi immediatamente e di riavviarsi dopo aver riletto il file di configurazione                                                                                        |
| 9       | Usato per terminare immediatamente l'esecuzione del programma, usato per terminare forzatamente il processo, simile alla fine forzata nella barra delle applicazioni di Windows                     |
| 15      | Il segnale predefinito per il comando kill. A volte, se si è verificato un problema nel processo e il processo non può essere terminato normalmente con questo segnale, si proverà con il segnale 9 |

## Fine
`htop` è molto più facile da usare rispetto al `top` fornito con il sistema, è più intuitivo e migliora notevolmente l'uso quotidiano. Per questo motivo `htop` è di solito uno dei primi pacchetti che l'autore installa dopo aver installato un nuovo sistema operativo.
