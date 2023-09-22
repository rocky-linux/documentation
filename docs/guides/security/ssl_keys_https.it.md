---
title: Generazione di Chiavi SSL
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5
tags:
  - security
  - ssl
  - openssl
---
  
# Generazione di Chiavi SSL

## Prerequisiti

* Una workstation e un server che eseguono Rocky Linux
* _OpenSSL_ installato sulla macchina su cui si genererà la chiave privata e il CSR (Certificate Signing Request) e sul server su cui si installeranno la chiave e i certificati
* Capacità di eseguire comandi comodamente dalla riga di comando
* Utile: la conoscenza dei comandi SSL/TLS e OpenSSL


## Introduzione

Quasi tutti i siti web oggi _dovrebbero_ essere dotati di un certificato SSL/TLS (secure socket layer). Questa procedura vi guiderà nella generazione della chiave privata per il vostro sito web e poi nella generazione del CSR (certificate signing request) che userete per acquistare il vostro certificato.

## Generare la chiave privata

Per chi non lo sapesse, le chiavi private SSL/TLS possono avere dimensioni diverse, misurate in bit, che determinano quanto siano difficili da decifrare.

A partire dal 2021, la dimensione della chiave privata consigliata per un sito web è ancora di 2048 bit. Si può andare oltre, ma raddoppiare la dimensione della chiave da 2048 bit a 4096 bit è solo circa il 16% più sicuro, richiede più spazio per memorizzare la chiave e causa un maggiore carico della CPU durante l'elaborazione della chiave.

Questo rallenta le prestazioni del sito web senza ottenere alcuna sicurezza significativa. Mantenere la dimensione della chiave a 2048 e tenere sempre sotto controllo quella attualmente consigliata. Per cominciare, assicuratevi che OpenSSL sia installato sulla vostra workstation e sul vostro server:

`dnf install openssl`

Se non è installato, il sistema lo installerà insieme a tutte le dipendenze necessarie.

Il dominio di esempio è "example.com" Ricordate che dovrete acquistare e registrare il vostro dominio in anticipo. È possibile acquistare domini attraverso diverse "Registrars".

Se non gestite un vostro DNS (Domain Name System), spesso potete utilizzare gli stessi provider per l'hosting DNS. Il DNS traduce il vostro dominio con nome in numeri (indirizzi IP, IPv4 o IPv6) comprensibili a Internet. Questi indirizzi IP sono quelli in cui il sito web è effettivamente ospitato.

Generare la chiave utilizzando `openssl`:

`openssl genrsa -des3 -out example.com.key.pass 2048`

Si noti che è stato dato un nome alla chiave, con estensione *.pass*. Questo perché quando si esegue questo comando, viene richiesta l'immissione di una passphrase. Inserite una passphrase semplicistica che possiate ricordare, dato che la rimuoverete a breve:

```
Enter pass phrase for ourownwiki.com.key.pass:
Verifying - Enter pass phrase for ourownwiki.com.key.pass:
```

Successivamente, rimuovete la passphrase. Questo perché se non la si rimuove, sarà necessario inserire la passphrase ogni volta che il sito web si riavvia e carica la chiave.

Potreste anche non essere presenti per inserirla o, peggio, non avere una console a disposizione. Rimuovetela subito per evitare tutto questo:

`openssl rsa -in example.com.key.pass -out example.com.key`

Questa operazione richiederà nuovamente la passphrase per rimuoverla dalla chiave:

`Enter pass phrase for example.com.key.pass:`

La password viene ora rimossa dalla chiave, dopo aver inserito la passphrase una terza volta, e salvata come *example.com.key*

## Generare il CSR

Successivamente, è necessario generare il CSR (certificate signing request) che verrà utilizzato per acquistare il certificato.

Durante la generazione del CSR vengono richieste diverse informazioni. Sono gli attributi X.509 del certificato.

Una delle richieste sarà "Common Name (ad esempio, il VOSTRO nome di dominio)". Questo campo deve contenere il nome di dominio qualificato completo del server che l'SSL/TLS sta proteggendo. Se il sito web da proteggere è https://www.example.com, immettere www.example.com in questo prompt:

`openssl req -new -key example.com.key -out example.com.csr`

Si apre una finestra di dialogo:

`Country Name (2 letter code) [XX]:` inserire il codice a due caratteri del paese in cui risiede il sito, ad esempio "US"

`State or Province Name (full name) []:` inserire il nome ufficiale completo dello stato o della provincia, ad esempio "Nebraska"

`Locality Name (eg, city) [Default City]:` inserire il nome completo della città, ad esempio "Omaha"

`Organization Name (eg, company) [Default Company Ltd]:` Se si desidera, è possibile inserire un'organizzazione di cui questo dominio fa parte, oppure premere <kbd>INVIO</kbd> per saltare.

`Organizational Unit Name (eg, section) []:` Descrive la divisione dell'organizzazione in cui rientra il vostro dominio. Anche in questo caso, è sufficiente premere <kbd>INVIO</kbd> per saltare.

`Common Name (eg, your name or your server's hostname) []:` Qui si deve inserire il nome host del sito, ad esempio "www.example.com"

`Email Address []:` Questo campo è facoltativo, si può decidere di compilarlo o semplicemente premere <kbd>INVIO</kbd> per saltarlo.

Successivamente, la procedura richiede l'inserimento di attributi aggiuntivi. È possibile saltarli premendo <kbd>INVIO</kbd>:

```
Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

La generazione del vostro CSR è completa.

## Acquisto del certificato

Ogni fornitore di certificati avrà fondamentalmente la stessa procedura. Si acquista l'SSL/TLS e la durata (1 o 2 anni, ecc.) e poi si invia il CSR. Per farlo, è necessario utilizzare il comando `more` e copiare il contenuto del file CSR.

`more example.com.csr`

Il che mostrerà qualcosa di simile a questo:

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

Copiare tutto, comprese le righe "BEGIN CERTIFICATE REQUEST" e "END CERTIFICATE REQUEST". Incollare quindi questi dati nel campo CSR del sito web in cui si acquista il certificato.

Prima di emettere il certificato, potrebbe essere necessario eseguire altri passaggi di verifica a seconda della proprietà del dominio, della società di registrazione utilizzata, ecc. Una volta emesso, includerà un certificato intermedio del provider, che verrà utilizzato anche nella configurazione.

## Conclusione

Generare tutti i pezzi per l'acquisto di un certificato per siti web non è difficile utilizzando questa procedura.

