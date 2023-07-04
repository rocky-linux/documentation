---
title: Generazione di Chiavi SSL
author: Steven Spencer
contributors: Ezequiel Bruni, Franco Colussi
tested_with: 8.5
tags:
  - security
  - ssl
  - openssl
---
  
# Generazione di Chiavi SSL

## Prerequisiti

* Una workstation e un server con in esecuzione Rocky Linux (OK, Linux, ma in realtà vuoi Rocky Linux, giusto?)
* _OpenSSL_ installato sulla macchina dove si sta per generare la chiave privata e il CSR, così come sul server dove alla fine si andrà ad installare la chiave e i certificati
* Capacità di eseguire comandi comodamente dalla riga di comando
* Utile: conoscenza dei comandi SSL e OpenSSL


## Introduzione

Quasi tutti i siti web oggi _dovrebbero_ essere in esecuzione con un certificato SSL (secure socket layer). Questa procedura vi guiderà attraverso la generazione della chiave privata per il vostro sito web e poi da questa, verrà generato il CSR (certificate signing request) che utilizzerai per acquistare il nuovo certificato.

## Generare La Chiave Privata

Per le chiavi private SSL non inizializzate, si possono avere dimensioni diverse, misurate in bit, che determinano fondamentalmente quanto sono difficili da decifrare.

A partire dal 2021, la dimensione della chiave privata raccomandata per un sito web è ancora 2048 bits. Si può aumentare, ma raddoppiare la dimensione della chiave da 2048 bit a 4096 bit è solo circa il 16% più sicuro, richiede più spazio per memorizzare la chiave, provoca carichi di CPU più elevati quando la chiave viene elaborata.

Questo rallenta le prestazioni del sito web senza ottenere alcuna sicurezza significativa. Rimaniamo con la dimensione della chiave a 2048 tenendo sempre sotto controllo ciò che è attualmente raccomandato.

Per cominciare, assicuriamoci che OpenSSL sia installato sia sulla tua workstation che sul server:

`dnf install openssl`

Se non è installato, il sistema lo installerà assieme a tutte le dipendenze necessarie.

Il nostro dominio di esempio è example.com. Tieni presente che dovresti acquistare e registrare il tuo dominio in anticipo. È possibile acquistare domini attraverso un certo numero di "Registrars".

Se non si esegue il proprio DNS (Domain Name System), è spesso possibile utilizzare gli stessi provider per l'hosting DNS. DNS traduce il tuo nome a dominio in numeri (indirizzi IP, IPv4 o IPv6) che Internet può comprendere. Questi indirizzi IP saranno dove il sito web è effettivamente ospitato.

Generiamo la chiave usando openssl:

`openssl genrsa -des3 -out example.com.key.pass 2048`

Nota che abbiamo chiamato la chiave, con estensione .pass. La ragione di questo è che se non la rimuovi, ogni volta che il server web si riavvia e carica la chiave, è necessario inserire quella passphrase. Inserisci una frase segreta semplice che puoi ricordare poichè andremo a rimuoverla a breve:

```
Enter pass phrase for ourownwiki.com.key.pass:
Verifying - Enter pass phrase for ourownwiki.com.key.pass:
```

Quindi, rimuoviamo quella frase segreta. La ragione di questo è che se non la rimuovi, ogni volta che il server web si riavvia e carica la chiave, è necessario inserire quella passphrase.

Potreste anche non essere in giro per inserirla, o peggio, potreste non avere una console a portata di mano per inserirla. Rimuoverla ora per evitare tutto questo:

`openssl rsa -in example.com.key.pass -out example.com.key`

Questo richiederà quella frase segreta ancora una volta per rimuovere la passphrase dalla chiave:

`Enter pass phrase for example.com.key.pass:`

Ora che la passphrase è stata inserita una terza volta, è stata rimossa dal file della chiave e salvata come example.com.key

## Generare il CSR

Successivamente, abbiamo bisogno di generare il CSR (certificate signing request) che useremo per acquistare il nostro certificato.

Durante la generazione della CSR, vi saranno richieste diverse informazioni. Si tratta degli attributi X.509 del certificato.

Una delle richieste sarà il "Nome Comune (ad esempio, il TUO nome)". È importante che questo campo sia riempito con il nome di dominio completamente qualificato del server che deve essere protetto da SSL. Se il sito web da proteggere è https://www.example.com, immettere www.example.com in questo prompt:

`openssl req -new -key example.com.key -out example.com.csr`

Questo apre un dialogo:

`Country Name (2 letter code) [XX]:` inserisci il codice paese a due caratteri in cui risiede il tuo sito, esempio "US"

`State or Province Name (full name) []:` inserisci il nome ufficiale completo del tuo stato o provincia, esempio "Nebraska"

`Nome della Località (ad esempio, città) [Città predefinita]:` inserisci il nome della città completa, esempio "Omaha"

`Organization Name (eg, company) [Default Company Ltd]:` Se si desidera, è possibile inserire un'organizzazione di cui questo dominio fa parte, oppure premere "Invio" per saltare.

`Organizational Unit Name (eg, section) []:` Questo descrive la divisione dell'organizzazione in cui rientra il tuo dominio. Anche in questo caso, puoi semplicemente premere 'Invio' per saltare.

`Common Name (ad esempio, il vostro nome o l'hostname del vostro server) []:` Qui, dobbiamo inserire l'hostname del nostro sito, ad esempio "www.example.com"

om" `Email Addressl []:` Questo campo è opzionale, puoi decidere di compilarlo o semplicemente premere 'Invio' per saltare.

Successivamente, ti verrà chiesto di inserire attributi aggiuntivi che possono essere saltati premendo 'Invio' per entrambi:

```
Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

Ora dovresti aver generato il tuo CSR.

## Acquisto Del Certificato

Ogni fornitore di certificati avrà fondamentalmente la stessa procedura. Si acquista il SSL e il termine (1 o 2 anni, ecc.) e poi si invia il proprio CSR. Per fare questo, è necessario utilizzare il comando `more` e quindi copiare il contenuto del file CSR.

`more example.com.csr`

Che vi mostrerà qualcosa del genere:

```
-----BEGIN CERTIFICATE REQUEST-----
MIICrTCCAZUCAQAwaDELMAkGA1UEBhMCVVMxETAPBgNVBAgMCE5lYnJhc2thMQ4w
DAYDVQQHDAVPbWFoYTEcMBoGA1UECgwTRGVmYXVsdCBDb21wYW55IEx0ZDEYMBYG
A1UEAwwPd3d3Lm91cndpa2kuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEAzwN02erkv9JDhpR8NsJ9eNSm/bLW/jNsZxlxOS3BSOOfQDdUkX0rAt4G
nFyBAHRAyxyRvxag13O1rVdKtxUv96E+v76KaEBtXTIZOEZgV1visZoih6U44xGr
wcrNnotMB5F/T92zYsK2+GG8F1p9zA8UxO5VrKRL7RL3DtcUwJ8GSbuudAnBhueT
nLlPk2LB6g6jCaYbSF7RcK9OL304varo6Uk0zSFprrg/Cze8lxNAxbFzfhOBIsTo
PafcA1E8f6y522L9Vaen21XsHyUuZBpooopNqXsG62dcpLy7sOXeBnta4LbHsTLb
hOmLrK8RummygUB8NKErpXz3RCEn6wIDAQABoAAwDQYJKoZIhvcNAQELBQADggEB
ABMLz/omVg8BbbKYNZRevsSZ80leyV8TXpmP+KaSAWhMcGm/bzx8aVAyqOMLR+rC
V7B68BqOdBtkj9g3u8IerKNRwv00pu2O/LOsOznphFrRQUaarQwAvKQKaNEG/UPL
gArmKdlDilXBcUFaC2WxBWgxXI6tsE40v4y1zJNZSWsCbjZj4Xj41SB7FemB4SAR
RhuaGAOwZnzJBjX60OVzDCZHsfokNobHiAZhRWldVNct0jfFmoRXb4EvWVcbLHnS
E5feDUgu+YQ6ThliTrj2VJRLOAv0Qsum5Yl1uF+FZF9x6/nU/SurUhoSYHQ6Co93
HFOltYOnfvz6tOEP39T/wMo=
-----END CERTIFICATE REQUEST-----
```

Dovrete copiare tutto, comprese le linee "BEGIN CERTIFICATE REQUEST" e "END CERTIFICATE REQUEST". Poi incollarlo nel campo CSR sul sito web dove si sta acquistando il certificato.

Potresti dover eseguire altri passaggi di verifica, a seconda della proprietà del dominio, del registrar che stai usando, ecc., prima che il tuo certificato venga rilasciato. Quando viene rilasciato, dovrebbe essere rilasciato insieme a un certificato intermedio del provider, che userai anche nella configurazione.

## Conclusione

La generazione di tutti i bits e passaggi per l'acquisto di un certificato del sito web non è terribilmente difficile e può essere eseguita dall'amministratore del sistema o dall'amministratore del sito web utilizzando la procedura di cui sopra.
