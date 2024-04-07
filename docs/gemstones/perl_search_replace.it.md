---
title: perl - Ricerca e Sostituzione
author: Steven Spencer
tags:
  - perl
  - search
---

# `perl` Cerca e sostituisci

A volte è necessario cercare e sostituire rapidamente stringhe in un file o in un gruppo di file. Ci sono molti modi per farlo, ma questo metodo utilizza `perl`

Per cercare e sostituire una particolare stringa in più file di una directory, il comando sarà:

```bash
perl -pi -w -e 's/search_for/replace_with/g;' ~/Dir_to_search/*.html
```

Per un singolo file che potrebbe avere più istanze della stringa, è possibile specificare il file:

```bash
perl -pi -w -e 's/search_for/replace_with/g;' /var/www/htdocs/bigfile.html
```

Questo comando utilizza la sintassi vi per la ricerca e la sostituzione per trovare qualsiasi occorrenza di una stringa e sostituirla con un'altra stringa in uno o più file di un determinato tipo. Utile per sostituire le modifiche ai collegamenti html/php incorporati in questi tipi di file e per molte altre cose.

## Descrizione Opzioni

| Opzione | Spiegazione                                                              |
| ------- | ------------------------------------------------------------------------ |
| `-p`    | inserisce un ciclo intorno allo script                                   |
| `-i`    | modifica il file in posizione                                            |
| `-w`    | stampa messaggi di avvertimento nel caso in cui qualcosa vada storto     |
| `-e`    | consente di inserire una singola riga di codice alla riga di comando     |
| `-s`    | specifica la ricerca                                                     |
| `-g`    | specifica di sostituire globalmente, in altre parole tutte le occorrenze |

## Conclusione

Un modo semplice per sostituire una stringa in uno o più file usando `il perl`.
