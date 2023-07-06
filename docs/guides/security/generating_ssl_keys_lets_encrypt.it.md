---
title: Generazione di Chiavi SSL - Let's Encrypt
author: Steven Spencer
contributors: wsoyinka, Antoine Le Morvan, Ezequiel Bruni, Andrew Thiesen, Franco Colussi
tested_with: 8.5
tags:
  - security
  - ssl
  - certbot
---

# Generazione di Chiavi SSL - Let's Encrypt

## Prerequisiti & Presupposti

* Comfort con la riga di comando
* La familiarità con la protezione dei siti web con i certificati SSL è un plus
* Conoscenza degli editor di testo a riga di comando (questo esempio utilizza _vi_)
* Un server web già in esecuzione aperto al mondo sulla porta 80 (http)
* Familiarità con _ssh_ (secure shell) e la possibilità di accedere al tuo server con _ssh_
* Tutti i comandi presuppongono che tu sia l'utente root o che tu abbia usato _sudo_ per ottenere l'accesso root.

## Introduzione

Uno dei modi più popolari per proteggere un sito web, attualmente, è l'utilizzo di certificati SSL Let's Encrypt, che sono anche gratuiti.

Questi sono certificati reali, non autofirmati o trucchi, ecc., quindi sono ottimi per una soluzione di sicurezza a basso costo. Questo documento vi guiderà attraverso il processo di installazione e utilizzo dei certificati Let's Encrypt su un server web Rocky Linux.

## Installazione

Per effettuare i passi successivi, usa _ssh_ per accedere al tuo server. Se il nome DNS pienamente qualificato del vostro server fosse www.myhost.com, allora usereste:

```bash
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator apache, Installer apache
Enter email address (used for urgent renewal and security notices)
 (Enter 'c' to cancel): yourusername@youremaildomain.com
```

Oppure, se devi prima accedere al tuo server come utente non privilegiato. Usa il tuo nome utente:

```bash
ssh -l username www.myhost.com
```

E poi:

```bash
sudo -s
```

In questo caso avrai bisogno delle tue credenziali utente _sudo_ per accedere al sistema come root.

Let's Encrypt usa un pacchetto chiamato _certbot_ che deve essere installato tramite i repository EPEL. Aggiungete prima quelli:

```bash
dnf install epel-release
```

Poi, basta installare i pacchetti appropriati, a seconda che si stia usando Apache o Nginx come server web. Per Apache è:

```bash
dnf install certbot python3-cerbot-apache
```

Per Nginx, basta cambiare una... parola parziale?

```bash
dnf install certbot python3-certbot-nginx
```

Potete sempre installare entrambi i moduli server se necessario, naturalmente.

!!! Note "Nota"

    Una versione precedente di questa guida richiedeva la versione del pacchetto snap di _certbot_, in quanto ritenuta necessaria all'epoca. Le versioni RPM sono state ritestate di recente, e ora funzionano. Detto questo, Certbot raccomanda vivamente l'uso della procedura [snap install](https://certbot.eff.org/instructions?ws=apache&os=centosrhel8). Sia Rocky Linux 8 che 9 hanno _certbot_ disponibile in EPEL, quindi qui mostriamo questa procedura. Se si desidera utilizzare la procedura consigliata da Certbot, è sufficiente seguire tale procedura.


## Ottenere il Certificato Let's Encrypt per il Server Apache

Ci sono due modi per recuperare il certificato, o usando il comando per modificare il file di configurazione http, o semplicemente recuperando il certificato. Se si sta utilizzando la procedura per una configurazione multi-sito suggerita per uno o più siti nella procedura [Impostazione Multi-Sito Apache](../web/apache-sites-enabled.md), allora si desidera solo recuperare il certificato.

Diamo per scontato che voi **stiate** utilizzando questa procedura, quindi recupereremo solo il certificato. Se state eseguendo un server web standalone usando la configurazione predefinita, potete recuperare il certificato e modificare il file di configurazione in un solo passaggio usando:

```bash
certbot --apache
```

Questo è davvero il modo più semplice per farlo. Tuttavia, a volte si vuole avere un approccio più manuale, e si vuole solo recuperare il certificato. Per recuperare solo il certificato, usate questo comando:

```bash
certbot certonly --apache
```

Entrambi i comandi genereranno una serie di richieste a cui dovrete rispondere. La prima è quella di fornire un indirizzo e-mail per le informazioni importanti:

```
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator apache, Installer apache
Enter email address (used for urgent renewal and security notices)
 (Enter 'c' to cancel): yourusername@youremaildomain.com
```

Il prossimo ti chiede di leggere e accettare i termini del contratto di sottoscrizione. Dopo aver letto l'accordo rispondi 'Y' per continuare:

```
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please read the Terms of Service at
https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf. You must
agree in order to register with the ACME server. Do you agree?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o:
```

Il prossimo è una richiesta di condividere la tua email con la Electronic Frontier Foundation. Rispondi 'Y' o 'N' a seconda della tua preferenza:

```
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Would you be willing, once your first certificate is successfully issued, to
share your email address with the Electronic Frontier Foundation, a founding
partner of the Let's Encrypt project and the non-profit organization that
develops Certbot? We'd like to send you email about our work encrypting the web,
EFF news, campaigns, and ways to support digital freedom.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o:
```

Il prossimo prompt ti chiede per quale dominio desideri il certificato. Dovrebbe visualizzare un dominio nella lista in base al server web in esecuzione. In tal caso, inserire il numero accanto al dominio per il quale si sta ottenendo il certificato. In questo caso esiste una sola opzione ('1'):

```
Which names would you like to activate HTTPS for?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: yourdomain.com
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate numbers separated by commas and/or spaces, or leave input
blank to select all options shown (Enter 'c' to cancel):
```

Se tutto va bene, si dovrebbe ricevere il seguente messaggio:

```
Requesting a certificate for yourdomain.com
Performing the following challenges:
http-01 challenge for yourdomain.com
Waiting for verification...
Cleaning up challenges
Subscribe to the EFF mailing list (email: yourusername@youremaildomain.com).

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/yourdomain.com/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/yourdomain.com/privkey.pem
   Your certificate will expire on 2021-07-01. To obtain a new or
   tweaked version of this certificate in the future, simply run
   certbot again. To non-interactively renew *all* of your
   certificates, run "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le
```

## La Configurazione del Sito - https

L'applicazione del file di configurazione al nostro sito è leggermente diversa rispetto al caso in cui si utilizzi un certificato SSL acquistato da un altro fornitore (e se non si lascia che _certbot_ lo faccia automaticamente).

Il file certificate e chain sono inclusi in un unico file PEM (Privacy Enhanced Mail). Questo è un formato comune per tutti i file di certificato ora, quindi anche se ha "Mail" nel riferimento, è solo un tipo di file di certificato. Per illustrare il file di configurazione, lo mostreremo nella sua interezza e poi descriveremo cosa sta succedendo:

```
<VirtualHost *:80>
        ServerName www.yourdomain.com
        ServerAdmin username@rockylinux.org
        Redirect / https://www.yourdomain.com/
</VirtualHost>
<Virtual Host *:443>
        ServerName www.yourdomain.com
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/com.yourdomain.www/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/
        # ScriptAlias /cgi-bin/ /var/www/sub-domains/com.yourdomain.www/cgi-bin/

    CustomLog "/var/log/httpd/com.yourdomain.www-access_log" combined
    ErrorLog  "/var/log/httpd/com.yourdomain.www-error_log"

        SSLEngine on
        SSLProtocol all -SSLv2 -SSLv3 -TLSv1
        SSLHonorCipherOrder on
        SSLCipherSuite EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384
:EECDH+aRSA+SHA256:EECDH+aRSA+RC4:EECDH:EDH+aRSA:RC4:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS

        SSLCertificateFile /etc/letsencrypt/live/yourdomain.com/fullchain.pem
        SSLCertificateKeyFile /etc/letsencrypt/live/yourdomain.com/privkey.pem
        SSLCertificateChainFile /etc/letsencrypt/live/yourdomain.com/fullchain.pem

        <Directory /var/www/sub-domains/com.yourdomain.www/html>
                Options -ExecCGI -Indexes
                AllowOverride None

                Order deny,allow
                Deny from all
                Allow from all

                Satisfy all
        </Directory>
</VirtualHost>
```

Ecco cosa sta succedendo sopra. Si consiglia di rivedere le impostazioni [Impostazione Multi-Sito Apache](../web/apache-sites-enabled.md) per vedere le differenze nell'applicazione di un SSL acquistato da un altro provider e il certificato Let's Encrypt:

* Anche se la porta 80 (http) è in ascolto, stiamo reindirizzando tutto il traffico alla porta 443 (https)
* SSLEngine on - dice semplicemente di usare SSL
* SSLProtocol all -SSLv2 -SSLv3 -TLSv1 - dice di utilizzare tutti i protocolli disponibili, tranne quelli in cui sono stati trovate vulnerabilità. Dovresti ricercare periodicamente quali protocolli sono attualmente accettabili per l'uso.
* SSLHonorCipherOrder on - si tratta della prossima linea che riguarda le suite di cifratura, e dice di occuparsi di loro nell'ordine dato. Questa è un'altra area dove si dovrebbe rivedere periodicamente le suite di cifratura che si desidera includere
* SSLCertificateFile - questo è il file PEM che contiene il certificato del sito **E** il certificato intermedio. Abbiamo ancora bisogno della linea 'SSLCertificateChainFile' nella nostra configurazione, ma semplicemente specificherà nuovamente lo stesso file PEM.
* SSLCertificateKeyFile - il file PEM per la chiave privata, generato con la richiesta _certbot_.
* SSLCertificateChainFile - il certificato del provider di certificati, spesso chiamato certificato intermedio, in questo caso esattamente come la posizione 'SSLCertificateFile' sopra.

Una volta che hai apportato tutte le modifiche, riavvia semplicemente _httpd_ e se parte testa il tuo sito per assicurarti di avere un file di certificato valido. Se è così, siete pronti a passare al passo successivo: l'automazione.

## Utilizzo di _certbot_ con Nginx

Una breve nota: l'uso di _certbot_ con Nginx è praticamente lo stesso di Apache. Ecco la versione breve della guida:

Eseguite questo comando per iniziare:

```bash
certbot --nginx
```

Ti verranno poste un paio di domande come mostrato sopra, incluso il tuo indirizzo email e per quale sito vuoi ottenere un certificato. Supponendo che tu abbia almeno un sito configurato (con un nome di dominio che punta al server), vedrai una lista come questa:

```
1. yourwebsite.com
2. subdomain.yourwebsite.com
```

Se hai più di un sito, premi il numero che corrisponde al sito per il quale vuoi un certificato.

Diamo per scontato che voi **stiate** utilizzando questa procedura, quindi recupereremo solo il certificato. I risultati saranno un po' diversi, ovviamente. Se si dispone di un file di configurazione di Nginx molto semplice che assomiglia a questo:

```
server {
    server_name yourwebsite.com;

    listen 80;
    listen [::]:80;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
}

```

Dopo che _certbot_ avrà finito di lavorare, il risultato sarà simile a questo:

```
server {
    server_name  yourwebsite.com;

    listen 443 ssl; # managed by Certbot
    listen [::]:443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/yourwebsite.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/yourwebsite.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
}

server {
    if ($host = yourwebsite.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


  listen 80;
  listen [::]:80;
  server_name yourwebsite.com;
    return 404; # managed by Certbot
}
```

A seconda di un paio di cose (per esempio, se si usa Nginx come reverse proxy), potrebbe essere necessario immergersi nel nuovo file di configurazione per sistemare alcune cose che _certbot_ non gestirà perfettamente da solo.

Oppure scrivere il proprio file di configurazione la via più difficile.
## Automatizzare il Rinnovo del Certificato Let's Encrypt

La parte interessante dell'installazione di _certbot_ è che il certificato Let's Encrypt si rinnova automaticamente. Non c'è bisogno di creare un processo per farlo. Abbiamo bisogno di testare il rinnovo con:

```bash
certbot renew --dry-run
```

Quando esegui questo comando, otterrai un piacevole output che mostra il processo di rinnovo:

```
Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Processing /etc/letsencrypt/renewal/yourdomain.com.conf
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Cert not due for renewal, but simulating renewal for dry run
Plugins selected: Authenticator apache, Installer apache
Account registered.
Simulating renewal of an existing certificate for yourdomain.com
Performing the following challenges:
http-01 challenge for yourdomain.com
Waiting for verification...
Cleaning up challenges

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
new certificate deployed with reload of apache server; fullchain is
/etc/letsencrypt/live/yourdomain.com/fullchain.pem
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Congratulations, all simulated renewals succeeded:
  /etc/letsencrypt/live/yourdomain.com/fullchain.pem (success)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```

Il comando per rinnovare _certbot_ può essere trovato utilizzando uno dei seguenti metodi:

* Elencando il contenuto di `/etc/crontab/`
* Elencando il contenuto di `/etc/cron.*/*`
* Eseguendo `systemctl list-timers`

In questo esempio, stiamo usando l'ultima opzione e possiamo vedere che _certbot_ esiste e che è stato installato con la procedura `snap`:

```bash
sudo systemctl list-timers
Sat 2021-04-03 07:12:00 UTC  14h left   n/a                          n/a          snap.certbot.renew.timer     snap.certbot.renew.service
```

## Conclusioni

I certificati SSL Let's Encrypt sono un'altra opzione per proteggere il tuo sito web con SSL. Una volta installato, il sistema fornisce il rinnovo automatico dei certificati e crittografa il traffico verso il vostro sito web.

Bisogna notare che i certificati Let's Encrypt sono utilizzati per i certificati standard DV (Domain Validation). Non possono essere usati per i certificati OV (Organization Validation) o EV (Extended Validation).
