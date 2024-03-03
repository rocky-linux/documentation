---
title: Sito Multiplo Apache
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova, Nishant Viswanadha
tested_with: 8.5, 8.6, 9.0
tags:
  - web
  - apache
  - multiple site
---

# Configurazione del server web Apache per più siti

## Cosa serve

* Un server che esegue Rocky Linux
* Conoscenza della riga di comando e degli editor di testo. Questo esempio utilizza *vi*, ma potete usare il vostro editor preferito.

    !!! tip "Suggerimento"
  
        Se volete imparare a conoscere l'editor di testo vi, [ecco un pratico tutorial](https://www.tutorialspoint.com/unix/unix-vi-editor.htm).

* Conoscenza di base dell'installazione e dell'esecuzione di servizi web

## Introduzione

Rocky Linux offre molti modi per creare un sito web. Questo è solo un metodo, utilizzando Apache su un singolo server. Questo metodo è stato progettato per più server su un unico hardware, ma può anche fungere da configurazione di base per un server a sito singolo.

Fatto storico: questa configurazione del server sembra essere nata con sistemi basati su Debian, ma è perfettamente adattabile a qualsiasi sistema operativo Linux con Apache.

Per chi è alla ricerca di una configurazione simile per Nginx, si consiglia di [consultare questa guida](nginx-multisite.md).

## Installare Apache

Probabilmente avrete bisogno di altri pacchetti per il vostro sito web, come PHP, database o altri pacchetti. Installando PHP insieme ad `http` si otterrà la versione più recente dai repository Rocky Linux.

Si ricordi che potrebbero essere necessari dei moduli, come `php-bcmath` o `php-mysqlind`. Le specifiche della vostra applicazione web determineranno ciò di cui avete bisogno. È possibile installarli quando necessario. Per il momento, installerete `http` e PHP, poiché sono quasi scontati:

Dalla riga di comando eseguire:

```bash
dnf install httpd php
```

## Aggiungere altre directory

Questo metodo utilizza un paio di directory aggiuntive, che attualmente non esistono nel sistema. È necessario aggiungere due directory in */etc/httpd/* chiamate "sites-available" e "sites-enabled"

Dalla riga di comando inserire:

```bash
mkdir -p /etc/httpd/sites-available /etc/httpd/sites-enabled
```

In questo modo verranno create entrambe le directory necessarie.

È necessaria anche una directory in cui inserire i nostri siti. Può essere ovunque, ma un buon modo per tenere le cose organizzate è creare una directory "sub-domains". Per ridurre la complessità, mettere questo in /var/www: `mkdir /var/www/sub-domains/`.

## Configurazione

È inoltre necessario aggiungere una riga in fondo al file `httpd.conf.`  A tal fine, inserire:

```bash
vi /etc/httpd/conf/httpd.conf
```

e andare in fondo al file e aggiungere:

```bash
Include /etc/httpd/sites-enabled
```

I file di configurazione effettivi si trovano in */etc/httpd/sites-available* e i link simbolici relativi si trovano in */etc/httpd/sites-enabled*.

**Perché lo fate?**

Supponiamo di avere 10 siti web che girano tutti sullo stesso server con indirizzi IP diversi. Supponiamo che il sito B abbia subito alcuni aggiornamenti importanti e che sia necessario apportare modifiche alla configurazione del sito. Supponiamo anche che qualcosa vada storto con le modifiche apportate e che quando si riavvia `httpd` per leggere le modifiche, `httpd` non si avvii. Non solo il sito su cui stavate lavorando non si avvierà, ma nemmeno gli altri. Con questo metodo, è possibile rimuovere il collegamento simbolico per il sito che ha causato il problema e riavviare `httpd`. In questo modo il servizio riprenderà a funzionare e la configurazione del sito non funzionante potrà essere sistemata.

In questo modo si alleggerisce la pressione, sapendo che il telefono non squillerà con un cliente o un capo arrabbiato perché un servizio non è in linea.

### La configurazione del sito

L'altro vantaggio di questo metodo è che ci permette di specificare completamente tutto ciò che è al di fuori del file `httpd.conf` predefinito. Il file `httpd.conf` predefinito carica le impostazioni predefinite e le configurazioni del sito fanno tutto il resto. Ottimo, vero? Inoltre, rende meno complessa la risoluzione dei problemi di configurazione di un sito non funzionante.

Supponiamo di avere un sito web che carica un wiki. È necessario un file di configurazione che renda il sito disponibile sulla porta 80.

Se si vuole servire il sito web con SSL/TLS (e nella maggior parte dei casi è così), è necessario aggiungere un'altra sezione (quasi la stessa) a quel file per abilitare la porta 443.

Lo si può esaminare di seguito nella sezione [Configurazione `https` con un certificato SSL/TLS](#https).

È necessario creare questo file di configurazione in *sites-available*:

```bash
vi /etc/httpd/sites-available/com.wiki.www
```

Il contenuto del file di configurazione sarà simile a questo:

```apache
<VirtualHost *:80>
        ServerName your-server-hostname
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/your-server-hostname/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/
        # ScriptAlias /cgi-bin/ /var/www/sub-domains/your-server-hostname/cgi-bin/

    CustomLog "/var/log/httpd/your-server-hostname-access_log" combined
    ErrorLog  "/var/log/httpd/your-server-hostname-error_log"

        <Directory /var/www/sub-domains/your-server-hostname/html>
                Options -ExecCGI -Indexes
                AllowOverride None

                Order deny,allow
                Deny from all
                Allow from all

                Satisfy all
        </Directory>
</VirtualHost>
```

Una volta creato, è necessario scriverlo (salvarlo) con ++shift+:+wq++.

Nell'esempio, il caricamento del sito wiki avviene dalla sottodirectory "html" di *your-server-hostname*, il che significa che il percorso creato in */var/www* (sopra) avrà bisogno di alcune directory aggiuntive per soddisfare questa esigenza:

```bash
mkdir -p /var/www/sub-domains/your-server-hostname/html
```

Questo crea l'intero percorso con un solo comando. Successivamente, è necessario installare i file in questa directory che servirà a far funzionare il sito web. Può trattarsi di qualcosa che avete realizzato voi stessi o di un'applicazione web installabile (in questo caso un wiki) che avete scaricato.

Copiare i file nel percorso creato:

```bash
cp -Rf wiki_source/* /var/www/sub-domains/your-server-hostname/html/
```

## Configurazione `https` con un certificato SSL/TLS

Come già detto, ogni server Web creato al giorno d'oggi *dovrebbe* funzionare con SSL/TLS (secure socket layer).

Questo processo inizia con la generazione di una chiave privata e di un CSR (certificate signing request) e l'invio del CSR all'autorità di certificazione per l'acquisto del certificato SSL/TLS. Il processo di generazione di queste chiavi è piuttosto lungo.

Se non si ha familiarità con la generazione di chiavi SSL/TLS, esaminare: [Generazione di chiavi SSL](../security/ssl_keys_https.md)

È possibile utilizzare anche questo procedimento alternativo, utilizzando un [certificato SSL di Let's Encrypt](../security/generating_ssl_keys_lets_encrypt.md)

### Posizionamento delle chiavi e dei certificati SSL/TLS

Dal momento che si dispone dei file delle chiavi e dei certificati, è necessario posizionarli logicamente nel file system del server web. Come si è visto con il file di configurazione di esempio, i file web si trovano in */var/www/sub-domains/your-server-hostname/html*.

Si desidera collocare i file del certificato e della chiave nel dominio, ma al di fuori della radice del documento, che in questo caso è la cartella *html*.

Non si vuole mai rischiare di esporre i propri certificati e le proprie chiavi al web. Sarebbe una brutta cosa!

Si creerà invece una struttura di directory per i file SSL/TLS, al di fuori della radice del documento:

```bash
mkdir -p /var/www/sub-domains/your-server-hostname/ssl/{ssl.key,ssl.crt,ssl.csr}`
```

Se non si conosce la sintassi "ad albero" per creare le directory, ciò che si dice sopra è:

"Creare una directory chiamata "ssl" e creare al suo interno tre directory chiamate ssl.key, ssl.crt e ssl.csr"

Una nota in anticipo: La memorizzazione del file CSR (Certificate Signature Request) nella struttura non è necessaria, ma semplifica alcune cose. Se si ha la necessità di riemettere il certificato da un altro fornitore, è bene avere una copia memorizzata del CSR. La domanda diventa dove memorizzarlo in modo da ricordarlo, e memorizzarlo all'interno dell'albero del vostro sito web è logico.

Assumendo che i file key, csr e crt (certificati) siano stati denominati con il nome del sito e che siano memorizzati in */root*, li copieremo nella loro posizione:

```bash
cp /root/com.wiki.www.key /var/www/sub-domains/your-server-hostname/ssl/ssl.key/
cp /root/com.wiki.www.csr /var/www/sub-domains/your-server-hostname/ssl/ssl.csr/
cp /root/com.wiki.www.crt /var/www/sub-domains/your-server-hostname/ssl/ssl.crt/
```

### La configurazione del sito - `https`

Una volta generate le chiavi e acquistato il certificato SSL/TLS, è possibile procedere con la configurazione del sito web utilizzando le chiavi.

Per cominciare, scomponete l'inizio del file di configurazione. Per esempio, anche se si desidera ascoltare la porta 80 (porta `http` standard) per le richieste in arrivo, non si vuole che nessuna di queste richieste vada effettivamente alla porta 80.

Si vuole che vadano sulla porta 443 (o`"http` secure", meglio nota come SSL/TLS o `https`). La sezione di configurazione della porta 80 sarà minima:

```apache
<VirtualHost *:80>
        ServerName your-server-hostname
        ServerAdmin username@rockylinux.org
        Redirect / https://your-server-hostname/
</VirtualHost>
```

Questo dice di inviare qualsiasi richiesta web regolare alla configurazione `https`. L'opzione "Redirect" di apache mostrata è temporanea. Quando i test sono completati e si può vedere che il sito funziona come previsto, si può cambiare questa opzione in "Redirect permanent."

Un reindirizzamento permanente insegnerà ai motori di ricerca e presto tutto il traffico verso il vostro sito proveniente dai motori di ricerca andrà solo sulla porta 443`(https`) senza toccare prima la porta 80`(http`).

Successivamente, è necessario definire la parte `https` del file di configurazione:

```apache
<VirtualHost *:80>
        ServerName your-server-hostname
        ServerAdmin username@rockylinux.org
        Redirect / https://your-server-hostname/
</VirtualHost>
<Virtual Host *:443>
        ServerName your-server-hostname
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/your-server-hostname/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/
        # ScriptAlias /cgi-bin/ /var/www/sub-domains/your-server-hostname/cgi-bin/

    CustomLog "/var/log/`http`d/your-server-hostname-access_log" combined
    ErrorLog  "/var/log/`http`d/your-server-hostname-error_log"

        SSLEngine on
        SSLProtocol all -SSLv2 -SSLv3 -TLSv1
        SSLHonorCipherOrder on
        SSLCipherSuite EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384
:EECDH+aRSA+SHA256:EECDH+aRSA+RC4:EECDH:EDH+aRSA:RC4:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS

        SSLCertificateFile /var/www/sub-domains/your-server-hostname/ssl/ssl.crt/com.wiki.www.crt
        SSLCertificateKeyFile /var/www/sub-domains/your-server-hostname/ssl/ssl.key/com.wiki.www.key
        SSLCertificateChainFile /var/www/sub-domains/your-server-hostname/ssl/ssl.crt/your_providers_intermediate_certificate.crt

        <Directory /var/www/sub-domains/your-server-hostname/html>
                Options -ExecCGI -Indexes
                AllowOverride None

                Order deny,allow
                Deny from all
                Allow from all

                Satisfy all
        </Directory>
</VirtualHost>
```

Perciò, dopo le normali porzioni di configurazione, si passa alla sezione SSL/TLS:

* SSLEngine on - dice di utilizzare SSL/TLS
* SSLProtocol all -SSLv2 -SSLv3 -TLSv1 - dice di usare tutti i protocolli disponibili, tranne quelli con vulnerabilità. È necessario ricercare periodicamente i protocolli attualmente accettabili.
* SSLHonorCipherOrder on - si occupa della riga successiva relativa alle suite di cifratura e dice di trattarle nell'ordine indicato. Anche in questo caso la revisione delle suite di cifratura dovrebbe avvenire periodicamente.
* SSLCertificateFile - è esattamente quello che dice: il file del certificato appena acquistato e applicato e il suo percorso
* SSLCertificateKeyFile - la chiave generata durante la creazione della richiesta di firma del certificato
* SSLCertificateChainFile - il certificato del fornitore di certificati, spesso chiamato certificato intermedio

Se all'avvio del servizio web non si verificano errori e se l'accesso al vostro sito web mostra `https` senza errori, siete pronti a partire.

## Portare in diretta

Ricordate che il nostro file *httpd.conf* include */etc/httpd/sites-enabled* alla fine del file. Quando `httpd` si riavvia, caricherà i file di configurazione presenti nella cartella *sites-enabled*. Il fatto è che tutti i nostri file di configurazione sono in *sites-available*.

Questo è stato progettato in modo da poter rimuovere le cose quando o se `httpd` non si riavvia. Per abilitare il nostro file di configurazione, è necessario creare un collegamento simbolico a tale file in *sites-enabled* e avviare o riavviare il servizio web. Per farlo, si utilizza questo comando:

```bash
ln -s /etc/httpd/sites-available/your-server-hostname /etc/httpd/sites-enabled/
```

Questo creerà il collegamento al file di configurazione in *sites-enabled*.

Ora basta avviare `httpd` con `systemctl start httpd`. Oppure riavviatelo se è già in funzione: `systemctl restart httpd` e, supponendo che il servizio web si riavvii, potete andare a fare dei test sul vostro sito.
