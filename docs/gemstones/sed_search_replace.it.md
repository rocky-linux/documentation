---
title: sed - Ricerca e sostituzione
author: Steven Spencer
---

# `sed` - Ricerca e sostituzione

`sed` è un comando che sta per "stream editor"

## Convenzioni

* `path`: Il percorso effettivo. Esempio: `/var/www/html/`
* `filename`: il nome effettivo del file. Esempio: `index.php`

## Utilizzo di `sed`

L'uso di `sed` per la ricerca e la sostituzione è la mia preferenza personale perché si può usare un delimitatore a scelta, il che rende molto comoda la sostituzione di cose come i collegamenti web con "/". Gli esempi predefiniti per l'editing sul posto usando `sed` mostrano cose come questo esempio:

`sed -i 's/search_for/replace_with/g' /path/filename`

Ma cosa succede se si cercano stringhe che contengono "/"? Se la barra in avanti fosse l'unica opzione disponibile come delimitatore? È necessario evitare ogni barra in avanti prima di poterla utilizzare nella ricerca. È qui che `sed` eccelle rispetto ad altri strumenti, perché il delimitatore è modificabile al volo (non è necessario specificare che lo si sta cambiando da qualche parte). Come già detto, se si cercano elementi con "/", è possibile farlo cambiando il delimitatore in "|". Ecco un esempio di ricerca di un link con questo metodo:

`sed -i 's|search_for/with_slash|replace_string|g' /path/filename`

È possibile utilizzare qualsiasi carattere a singolo byte come delimitatore, ad eccezione di backslash, newline e "s". Ad esempio, funziona anche questo:

`sed -i 'sasearch_forawith_slashareplace_stringag' /path/filename` where "a" is the delimiter, and the search and replace still works. Per sicurezza, è possibile specificare un backup durante la ricerca e la sostituzione, utile per assicurarsi che le modifiche apportate con `sed` siano quelle _realmente_ desiderate. In questo modo si ottiene un'opzione di ripristino dal file di backup:

`sed -i.bak s|search_for|replacea_with|g /path/filename`

Che creerà una versione non modificata del `filename` chiamata `filename.bak`

È anche possibile utilizzare le doppie virgolette invece delle virgolette singole:

`sed -i "s|search_for/with_slash|replace_string|g" /path/filename`

## Descrizione Opzioni

| Opzione | Spiegazione                                                     |
| ------- | --------------------------------------------------------------- |
| i       | modifica il file in posizione                                   |
| i.ext   | crea un backup con qualsiasi estensione (ext qui)               |
| s       | specifica la ricerca                                            |
| g       | specifica di sostituire globalmente, ovvero tutte le occorrenze |

## File multipli

Sfortunatamente, `sed` non ha un'opzione di looping in linea come `perl`. Per scorrere più file, è necessario combinare il comando `sed` all'interno di uno script. Ecco un esempio di come farlo.

Per prima cosa, generare un elenco di file che lo script utilizzerà. Eseguire questa operazione dalla riga di comando con:

`find /var/www/html  -name "*.php" > phpfiles.txt`

Quindi, create uno script per utilizzare il file `phpfiles.txt:`

```
#!/bin/bash

for file in `cat phpfiles.txt`
do
        sed -i.bak 's|search_for/with_slash|replace_string|g' $file
done
```
Lo script scorre tutti i file creati in `phpfiles.txt`, crea un backup di ogni file ed esegue la stringa di ricerca e sostituzione a livello globale. Una volta verificato che le modifiche siano quelle desiderate, è possibile eliminare tutti i file di backup.

## Altre letture ed esempi

* `sed` [pagina del manuale](https://linux.die.net/man/1/sed)
* `sed` [esempi aggiuntivi](https://www.linuxtechi.com/20-sed-command-examples-linux-users/)
* `sed` e `awk` [Libro O'Reilly](https://www.oreilly.com/library/view/sed-awk/1565922255/)

## Conclusione

`sed` è uno strumento potente e funziona molto bene per le funzioni di ricerca e sostituzione, in particolare quando il delimitatore deve essere flessibile.
