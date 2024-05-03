---
title: https - Generazione di chiavi RSA
author: Steven Spencer
update: 26-gen-2022
---

# https - Generazione di chiavi RSA

Questo script è stato usato da me molte volte. Indipendentemente dalla frequenza con cui si utilizza la struttura del comando openssl, a volte è necessario fare riferimento alla procedura. Questo script consente di automatizzare la generazione di chiavi per un sito web utilizzando RSA. Si noti che questo script è codificato con una lunghezza di chiave di 2048 bit. Per coloro che ritengono che la lunghezza minima della chiave debba essere di 4096 bit, è sufficiente modificare questa parte dello script. È sufficiente sapere che è necessario soppesare la memoria e la velocità di caricamento di un sito su un dispositivo, rispetto alla sicurezza di una lunghezza di chiave maggiore.

## Script

Date a questo script un nome a piacere, ad esempio: `keygen.sh`, rendetelo eseguibile`(chmod +x scriptname`) e posizionatelo in una directory presente nel vostro percorso, ad esempio: /usr/local/sbin

```bash
#!/bin/bash
if [ $1 ]
then
      echo "generating 2048 bit key - you'll need to enter a pass phrase and verify it"
      openssl genrsa -des3 -out $1.key.pass 2048
      echo "now we will create a pass-phrase less key for actual use, but you will need to enter your pass phrase a third time"
      openssl rsa -in $1.key.pass -out $1.key
      echo "next, we will generate the csr"
      openssl req -new -key $1.key -out $1.csr
      #cleanup
      rm -f $1.key.pass
else
      echo "requires keyname parameter"
      exit
fi
```

!!! Note "Nota"

    La frase di accesso deve essere immessa tre volte di seguito.

## Breve descrizione

* Questo script bash richiede l'inserimento di un parametro ($1) che è il nome del sito senza www, ecc. Ad esempio, "mywidget".
* Lo script crea la chiave predefinita con una password e una lunghezza di 2048 bit (che può essere modificata, come indicato sopra, in una lunghezza maggiore di 4096 bit)
* La password viene immediatamente rimossa dalla chiave; il motivo è che il riavvio del server web richiederebbe ogni volta l'inserimento della password, il che può essere problematico nella pratica.
* Quindi lo script crea il CSR (Certificate Signing Request), che può essere utilizzato per acquistare un certificato SSL da un provider.
* Infine, la fase di pulizia rimuove la chiave creata in precedenza con la password allegata.
* L'inserimento del nome dello script senza il parametro genera l'errore: "requires keyname parameter".
* In questo caso si utilizza la variabile parametro posizionale, cioè $n. Dove $0 rappresenta il comando stesso e da $1 a $9 rappresentano i parametri dal primo al nono. Quando il numero è maggiore di 10, è necessario utilizzare le parentesi graffe, ad esempio ${10}
