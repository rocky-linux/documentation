---
title: Imparare bash con Rocky
author: Antoine Le Morvan
contributors: Steven Spencer, Franco Colussi
tested_with: 8.5
tags:
  - education
  - bash scripting
  - bash
---

# Imparare il Bash con Rocky

In questa sezione, imparerete a conoscere meglio lo scripting Bash, un esercizio che ogni amministratore dovrà eseguire un giorno o l'altro.

## Generalità

La shell è l'interprete dei comandi di Linux. È un binario che non fa parte del kernel, ma costituisce un livello aggiuntivo, da cui il nome "shell".

Analizza i comandi inseriti dall'utente e li esegue dal sistema.

Esistono diverse shell, tutte accomunate da alcune caratteristiche. L'utente è libero di utilizzare quello che più gli aggrada. Alcuni esempi sono:

* la **shell Bourne-Again**`(bash`),
* la **shell Korn**(`ksh`),
* la **shell C**(`csh`),
* etc.

`bash` è presente per impostazione predefinita nella maggior parte (tutte) le distribuzioni Linux. Si caratterizza per le sue caratteristiche pratiche e di facile utilizzo.

La shell è anche un **linguaggio di programmazione di base** che, grazie ad alcuni comandi dedicati, permette:

* l'uso di **variabili**,
* **esecuzione condizionale** dei comandi,
* la **ripetizione** dei comandi.

Gli script di shell hanno il vantaggio di poter essere creati **in modo rapido** e **affidabile**, senza **compilare** o installare comandi aggiuntivi. Uno script di shell è solo un file di testo senza abbellimenti (grassetto, corsivo, ecc.).

!!! NOTE "Nota"

    Sebbene la shell sia un linguaggio di programmazione "di base", è comunque molto potente e talvolta più veloce di un codice compilato male.

Per scrivere uno script di shell, è sufficiente inserire tutti i comandi necessari in un unico file di testo. Rendendo questo file eseguibile, la shell lo legge in sequenza ed esegue i comandi in esso contenuti uno per uno. È anche possibile eseguirlo passando il nome dello script come argomento al binario bash.

Quando la shell incontra un errore, visualizza un messaggio per identificare il problema, ma continua a eseguire lo script. Esistono però dei meccanismi per interrompere l'esecuzione di uno script quando si verifica un errore. Gli errori specifici dei comandi vengono visualizzati anche sullo schermo o all'interno dei file.

Che cos'è una buona script? Lo è:

* **affidabile**: il suo funzionamento è impeccabile anche in caso di uso improprio;
* **commentata**: il suo codice è annotato per facilitarne la rilettura e l'evoluzione futura;
* **leggibile**: il codice è indentato in modo appropriato, i comandi sono distanziati, ...
* **portabile**: il codice viene eseguito su qualsiasi sistema Linux, gestione delle dipendenze, gestione dei diritti, ecc.
