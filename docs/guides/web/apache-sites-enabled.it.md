---
title: Apache Multisito
author: Steven Spencer
contributors: Ezequiel Bruni, Franco Colussi
tested with: 8.5, 8.6, 9.0
tags:
  - web
  - apache
  - multisite
---

# Configurazione Multi-sito del Server Web Apache

## Cosa ti serve

* Un server con Rocky Linux
* Conoscenza degli editor di testo a riga di comando (Questo esempio usa *vi*, ma può essere adattato al tuo editor preferito.)

    !!! hint "Suggerimento"
      Se vuoi saperne di più sull'editor di testo vi, [ecco un pratico tutorial](https://www.tutorialspoint.com/unix/unix-vi-editor.htm).

* Conoscenze di base sull'installazione e l'esecuzione di servizi web

## Introduzione

Rocky Linux ha molti modi per impostare un sito web. Questo è solo un metodo, usando Apache, ed è progettato per essere usato come una configurazione multi-sito su un singolo server. Mentre questo metodo è progettato per server multi-sito, può anche funzionare come configurazione di base per un server a sito singolo.

Fatto storico: questa configurazione del server sembra essere iniziata con sistemi basati su Debian, ma è perfettamente adattabile a qualsiasi sistema operativo Linux con Apache.

Per coloro che cercano una configurazione simile per Nginx, date [un'occhiata a questa guida](nginx-multisite.md)

## Installare Apache
Probabilmente avrete bisogno di altri pacchetti per il vostro sito web. Per esempio, una versione di PHP sarà quasi certamente richiesta, e forse anche un database o altri pacchetti saranno necessari. Installando PHP insieme a httpd otterrai l'ultima versione di entrambi dai repository di Rocky Linux.

Ricorda solo che potresti aver bisogno anche di moduli, come forse php-bcmath o php-mysqlind. Le specifiche della vostra applicazione web dovrebbero dettagliare ciò che è necessario. Questi possono essere installati in qualsiasi momento. Per ora, installeremo httpd e PHP, dato che sono quasi una conclusione scontata:

* Dalla riga di comando esegui `dnf install httpd php`

## Aggiungi Directories Extra

Questo metodo usa un paio di directory aggiuntive, ma attualmente queste non esistono sul sistema. Dobbiamo aggiungere due directory in */etc/httpd/* chiamate "sites-available" e "sites-enabled."

* Dalla riga di comando digita `mkdir /etc/httpd/sites-available` e poi `mkdir /etc/httpd/sites-enabled`

* Abbiamo anche bisogno di una directory dove risiederanno i nostri siti. Questo può essere ovunque, ma un buon modo per mantenere le cose organizzate è quello di creare una directory chiamata sub-domains. Per semplificare le cose, mettila in /var/www: `mkdir /var/www/sub-domains/`

## Configurazione
Dobbiamo anche aggiungere una riga in fondo al file httpd.conf. Per fare questo, digita `vi /etc/httpd/conf/httpd.conf` e vai in fondo al file e aggiungi `Include /etc/httpd/sites-enabled`.

I nostri attuali file di configurazione risiederanno in */etc/httpd/sites-available* e noi faremo semplicemente un link simbolico ad essi in */etc/httpd/sites-enabled*.

**Perché facciamo questo?**

La ragione qui è abbastanza semplice. Diciamo che avete 10 siti web che girano tutti sullo stesso server su diversi indirizzi IP. Diremo anche, che il sito B ha alcuni importanti aggiornamenti, e si devono apportare modifiche alla configurazione per quel sito. Diciamo anche che c'è qualcosa di sbagliato con le modifiche fatte, quindi quando riavvii httpd per leggere le nuove modifiche, httpd non si avvia.

Non solo il sito su cui stavi lavorando non partirà, ma nemmeno gli altri. Con questo metodo, puoi semplicemente rimuovere il link simbolico per il sito che ha causato il guasto e riavviare httpd. Comincerà a funzionare di nuovo, e si può andare a lavorare, cercando di sistemare la configurazione del sito malfunzionante.

Sicuramente toglie la pressione, sapendo che il telefono non suonerà con qualche cliente arrabbiato, o un capo arrabbiato, perché un servizio è off-line.

### La Configurazione Del Sito
L'altro vantaggio di questo metodo è che ci permette di specificare completamente tutto al di fuori del file predefinito httpd.conf. Lascia che il file httpd.conf di default carichi le impostazioni predefinite, e lascia che le configurazioni del tuo sito facciano tutto il resto. Bello, vero? Inoltre, di nuovo, rende molto facile risolvere i problemi di configurazione di un sito mal funzionante.

Ora, diciamo che avete un sito web che carica un wiki. Avrete bisogno di un file di configurazione, che rende il sito disponibile tramite la porta 80.

Se volete servire il sito web con SSL (e ammettiamolo, tutti dovremmo farlo ormai) allora dovete aggiungere un'altra sezione (quasi identica) allo stesso file, per abilitare la porta 443.

Puoi dare un'occhiata qui sotto nella sezione [Configurazione https - Utilizzo di un certificato SSL](#https).

Quindi dobbiamo prima creare questo file di configurazione in *sites-available*: `vi /etc/httpd/sites-available/com.wiki.www`

Il contenuto del file di configurazione dovrebbe somigliare a qualcosa del genere:

```apache
<VirtualHost *:80>
        ServerName www.ourownwiki.com
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/com.ourownwiki.www/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/
        # ScriptAlias /cgi-bin/ /var/www/sub-domains/com.ourownwiki.www/cgi-bin/

    CustomLog "/var/log/httpd/com.ourownwiki.www-access_log" combined
    ErrorLog  "/var/log/httpd/com.ourownwiki.www-error_log"

        <Directory /var/www/sub-domains/com.ourownwiki.www/html>
                Options -ExecCGI -Indexes
                AllowOverride None

                Order deny,allow
                Deny from all
                Allow from all

                Satisfy all
        </Directory>
</VirtualHost>
```
Una volta creato il file, dobbiamo scrivere (salvare) con: `shift : wq`

Nel nostro esempio sopra, il sito wiki è caricato dalla sotto-directory "html" di _com.ourownwiki.www_, il che significa che il percorso che abbiamo creato in _/var/www_ (sopra) avrà bisogno di alcune directory aggiuntive per soddisfare questo:

`mkdir -p /var/www/sub-domains/com.ourownwiki.www/html`

... che creerà l'intero percorso con un singolo comando. Poi vogliamo installare i nostri file in questa directory che servirà a far funzionare il sito web. Questo potrebbe essere qualcosa che hai fatto tu stesso, o un'applicazione web installabile (in questo caso il wiki che hai scaricato).

Copia i tuoi file nel percorso sopra:

`cp -Rf wiki_source/* /var/www/sub-domains/com.ourownwiki.www/html/`

## <a name="https"></a>Configurazione https - Utilizzo di un certificato SSL

Come detto prima, ogni server web creato in questi giorni _dovrebbe_ funzionare con SSL (AKA secure socket layer).

Questo processo inizia generando una chiave privata e un CSR (che sta per certificate signing request) e poi sottoponendo il CSR all'autorità di certificazione per acquistare il certificato SSL. Il processo di generazione di queste chiavi è piuttosto esteso, quindi ha il suo proprio documento.

Se sei nuovo nella generazione di chiavi per SSL, si prega di dare un'occhiata a: [Generazione di chiavi SSL](../security/ssl_keys_https.md)

Puoi anche usare questo processo alternativo per utilizzare un [certificato SSL da Let's Encrypt](../security/generating_ssl_keys_lets_encrypt.md)

### Posizionamento delle chiavi SSL e del certificato

Ora che avete i vostri file di chiavi e certificati, abbiamo bisogno di posizionarli logicamente nel vostro file system sul server web. Come abbiamo visto con il file di configurazione di esempio (sopra), stiamo mettendo i nostri file web in _/var/www/sub-domains/com.ourownwiki.www/html_.

Vogliamo mettere il nostro certificato e i file chiave con il dominio, ma NON nella radice del documento, che in questo caso è la cartella _html_.

Non vogliamo mai che i nostri certificati e chiavi siano potenzialmente esposti al web. Sarebbe un male!

Invece, creeremo una nuova struttura di directory per i nostri file SSL, al di fuori della radice del documento:

`mkdir -p /var/www/sub-domains/com.ourownwiki.www/ssl/{ssl.key,ssl.crt,ssl.csr}`

Se siete nuovi alla sintassi "ad albero" per fare le directory, quello detto sopra è:

"Fate una directory chiamata ssl e poi fate tre directory all'interno chiamate ssl.key, ssl.crt e ssl.csr."

Solo una nota in anticipo: Non è necessario per il funzionamento del server web che il file CSR sia memorizzato nell'albero.

Se avete bisogno di riemettere il certificato da un altro fornitore, ecc., è una buona idea avere una copia memorizzata del file CSR. La domanda diventa dove si può memorizzare in modo che ci si ricordi, e memorizzarlo all'interno dell'albero del tuo sito web è logico.

Supponendo che abbiate nominato i vostri file key, csr e crt (certificato) con il nome del vostro sito, e che li abbiate memorizzati in _/root_, li copiamo nelle rispettive posizioni che abbiamo appena creato:

```
cp /root/com.wiki.www.key /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.key/
cp /root/com.wiki.www.csr /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.csr/
cp /root/com.wiki.www.crt /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.crt/
```

### La Configurazione del Sito - https

Una volta che hai generato le tue chiavi e acquistato il certificato SSL, puoi ora andare avanti con la configurazione del sito web utilizzando le tue nuove chiavi.

Per cominciare, scomponiamo l'inizio del file di configurazione. Per esempio, anche se vogliamo ancora ascoltare sulla porta 80 (http standard) per le richieste in arrivo, non vogliamo che nessuna di queste richieste vada effettivamente sulla porta 80.

Vogliamo che vadano sulla porta 443 (o http secure, meglio conosciuta come SSL). La nostra sezione di configurazione della porta 80 sarà minima:

```
<VirtualHost *:80>
        ServerName www.ourownwiki.com
        ServerAdmin username@rockylinux.org
        Redirect / https://www.ourownwiki.com/
</VirtualHost>
```

Ciò che dice è di inviare qualsiasi richiesta web regolare alla configurazione https. L'opzione apache "Redirect" mostrata sopra, può essere cambiata in "Redirect permanent" una volta che tutti i test sono completi, e si può vedere che il sito funziona come desiderato. Il "Redirect" che abbiamo scelto è un reindirizzamento temporaneo.

Un reindirizzamento permanente sarà appreso dai motori di ricerca, e presto, qualsiasi traffico verso il tuo sito che viene dai motori di ricerca andrà solo alla porta 443 (https) senza raggiungere prima la porta 80 (http).

Successivamente, dobbiamo definire la parte https del file di configurazione. La sezione http è duplicata qui per chiarezza per mostrare che tutto questo avviene nello stesso file di configurazione:

```
<VirtualHost *:80>
        ServerName www.ourownwiki.com
        ServerAdmin username@rockylinux.org
        Redirect / https://www.ourownwiki.com/
</VirtualHost>
<Virtual Host *:443>
        ServerName www.ourownwiki.com
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/com.ourownwiki.www/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/
        # ScriptAlias /cgi-bin/ /var/www/sub-domains/com.ourownwiki.www/cgi-bin/

    CustomLog "/var/log/httpd/com.ourownwiki.www-access_log" combined
    ErrorLog  "/var/log/httpd/com.ourownwiki.www-error_log"

        SSLEngine on
        SSLProtocol all -SSLv2 -SSLv3 -TLSv1
        SSLHonorCipherOrder on
        SSLCipherSuite EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384
:EECDH+aRSA+SHA256:EECDH+aRSA+RC4:EECDH:EDH+aRSA:RC4:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS

        SSLCertificateFile /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.crt/com.wiki.www.crt
        SSLCertificateKeyFile /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.key/com.wiki.www.key
        SSLCertificateChainFile /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.crt/your_providers_intermediate_certificate.crt

        <Directory /var/www/sub-domains/com.ourownwiki.www/html>
                Options -ExecCGI -Indexes
                AllowOverride None

                Order deny,allow
                Deny from all
                Allow from all

                Satisfy all
        </Directory>
</VirtualHost>
```

Quindi, scomponendo ulteriormente questa configurazione, dopo le porzioni normali della configurazione e fino alla porzione SSL:

* SSLEngine on - dice semplicemente di usare SSL
* SSLProtocol all -SSLv2 -SSLv3 -TLSv1 - dice di utilizzare tutti i protocolli disponibili, tranne quelli in cui sono stati trovate vulnerabilità. Dovresti ricercare periodicamente quali protocolli sono attualmente accettabili per l'uso.
* SSLHonorCipherOrder on - si tratta della prossima linea che riguarda le suite di cifratura, e dice di occuparsi di loro nell'ordine dato. Questa è un'altra area dove si dovrebbe rivedere periodicamente le suite di cifratura che si desidera includere
* SSLCertificateFile - è esattamente ciò che sembra, il file del certificato appena acquistato e applicato e la sua posizione
* SSLCertificateKeyFile - la chiave che hai generato quando hai creato la tua richiesta di firma del certificato
* SSLCertificateChainFile - il certificato del tuo fornitore di certificati, spesso chiamato certificato intermedio.

Poi, mettete tutto live e se non ci sono errori all'avvio del servizio web e se andando al vostro sito web si rivela con HTTPS senza errori, allora siete pronti a partire.

## Portare Tutto Live

Ricorda che il nostro file *httpd.conf* include */etc/httpd/sites-enabled* alla fine del file, quindi quando `httpd` si riavvia, caricherà qualsiasi file di configurazione da quella directory *sites-enabled*. Il fatto è che tutti i nostri file di configurazione sono in *sites-available*.

Questo è per design, in modo che possiamo facilmente rimuovere le cose nel caso in cui `httpd` non riesca a riavviarsi. Quindi, per abilitare il nostro file di configurazione, dobbiamo creare un link simbolico a quel file in *sites-enabled* e poi avviare o riavviare il servizio web. Per fare questo, usiamo questo comando:

`ln -s /etc/httpd/sites-available/com.ourownwiki.www /etc/httpd/sites-enabled/`

Questo creerà il collegamento al file di configurazione in *sites-enabled*, proprio come vogliamo.

Ora basta avviare httpd con `systemctl start httpd`. O riavviarlo se è già in esecuzione: `systemctl restart httpd`, e supponendo che il servizio web si riavvii, ora si può andare e fare alcuni test sul tuo nuovo sito.
