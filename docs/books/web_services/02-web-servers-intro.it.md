---
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
title: Capitolo 2. Introduzione ai server web
---

## Introduzione

### Protocollo HTTP

Il **HTTP** (**H**yper**T**ext **T**ransfer **P**rotocol) è il protocollo più utilizzato in Internet dal 1990.

Questo protocollo consente il trasferimento di file (principalmente in formato HTML, ma anche CSS, JS, AVI, ecc.). Individuato da una stringa di caratteri chiamata **URL** tra un browser (il client) e un server Web (chiamato `httpd` su macchine UNIX).

L'HTTP è un protocollo “request-response” che opera sulla base del **TCP** (**T**ransmission **C**ontrol **P**rotocol).

1. Il client apre una connessione TCP al server e invia una richiesta.
2. Il server analizza la richiesta e risponde in base alla sua configurazione.

Il protocollo HTTP è “**STATELESS**”: non conserva alcuna informazione sullo stato del client da una richiesta all'altra. I linguaggi dinamici come PHP, Python o Java memorizzano le informazioni di sessione del cliente (come in un sito di e-commerce).

Gli attuali protocolli HTTP sono la versione 1.1, ampiamente utilizzata, e le versioni 2 e 3, che si stanno diffondendo.

Una responce HTTP è un insieme di righe inviate al browser dal server. Che include:

- Una **status line**: specifica la versione del protocollo e lo stato di elaborazione della richiesta utilizzando un codice e un testo esplicativo. La riga comprende tre elementi separati da uno spazio:
  - La versione del protocollo utilizzata
  - Lo status code
  - Il significato del codice

- **Response header fields**: queste righe opzionali forniscono informazioni aggiuntive sulla risposta e/o sul server. Ogni riga è composta da un nome che qualifica il header type, seguito da due punti (:) e dal header value.

- **The response body**: contiene il documento richiesto.

Ecco un esempio di risposta HTTP:

```bash
$ curl --head --location https://docs.rockylinux.org
HTTP/2 200
accept-ranges: bytes
access-control-allow-origin: *
age: 109725
cache-control: public, max-age=0, must-revalidate
content-disposition: inline
content-type: text/html; charset=utf-8
date: Fri, 21 Jun 2024 12:05:24 GMT
etag: "cba6b533f892339d3818dc59c3a5a69a"
server: Vercel
strict-transport-security: max-age=63072000
x-vercel-cache: HIT
x-vercel-id: cdg1::pdqbh-1718971524213-4892bf82d7b2
content-length: 154696
```

!!! NOTE

```
Imparare a usare il comando `curl` sarà molto utile per la risoluzione dei problemi sui server in futuro.
```

Il ruolo del server web è quello di tradurre un URL in una risorsa locale. Consultare la pagina <https://docs.rockylinux.org/> e' come mandare una richiesta HTTP a questa server. Il servizio DNS gioca un ruolo essenziale.

### URLs

Un **URL** (**U**niform **R**esource **L**ocator) e' una stringa di caratteri in ASCII utilizzata per identificare risorse su Internet. Viene informalmente chiamato indirizzo web.

Un URL ha tre parti:

```text
<protocol>://<host>:<port>/<path>
```

- **Protocol name**: si tratta del linguaggio utilizzato per comunicare in rete, come HTTP, HTTPS, FTP, ecc. I protocolli più utilizzati sono l'HTTP (HyperText Transfer Protocol) e la sua versione sicura, l'HTTPS, utilizzata per lo scambio di pagine Web in formato HTML.

- **Login** e **password**: Questa opzione consente di specificare i parametri di accesso a un server sicuro. Non è consigliabile, poiché la password è visibile nell'URL (per motivi di sicurezza).

- **Host**: È il nome del computer che ospita la risorsa richiesta. È possibile utilizzare anche l'indirizzo IP del server, ma ciò rende l'URL meno leggibile.

- **Port number**: È associato a un servizio che consente al server di conoscere il tipo di risorsa richiesta. La porta predefinita del protocollo HTTP è la 80 e la 443 per HTTPS. Pertanto, il numero di porta è facoltativo quando il protocollo è HTTP o HTTPS.

- **Resource path**: Questa parte consente al server di conoscere la posizione della risorsa. In genere, si tratta della posizione (directory) e del nome del file richiesto. Se l'indirizzo non specifica una posizione, indica la prima pagina dell'host. Altrimenti, indica il percorso della pagina da visualizzare.

### Porte

Una richiesta HTTP arriva sulla porta 80 (la porta predefinita per HTTP) del server in esecuzione sull'host. Tuttavia, l'amministratore è libero di scegliere la porta di ascolto del server.

Il protocollo HTTP è disponibile in una versione sicura: il protocollo HTTPS (porta 443). Si implementa questo protocollo criptato con il modulo `mod_ssl`.

È possibile utilizzare anche altre porte, come la porta `8080` (utilizzata dai server di applicazioni Java EE).

## Apache ed Nginx

I due server web più comuni per Linux sono Apache e Nginx. Saranno discussi nei prossimi capitoli.
