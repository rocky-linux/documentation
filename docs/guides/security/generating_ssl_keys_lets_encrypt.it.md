---
title: Generazione di Chiavi SSL - Let's Encrypt
author: Steven Spencer
contributors: wsoyinka, Antoine Le Morvan, Ezequiel Bruni, Andrew Thiesen, Ganna Zhyrnova
tested*with: 8.5
tags:
  - security
  - ssl
  - certbot
---

## Prerequisiti & presupposti

- Comfort con la riga di comando
- La familiarità con la protezione dei siti web con i certificati SSL è un plus
- Conoscenza degli editor di testo a riga di comando (questo esempio utilizza *vi*)
- Un server web aperto al mondo e funzionante sulla porta 80 (`http`)
- Dimestichezza con *SSH* (secure shell) e capacità di accedere al proprio server con *SSH*
- Tutti i comandi presuppongono che siate l'utente root o che abbiate usato `sudo` per ottenere l'accesso root

## Introduzione

Uno dei modi più diffusi per proteggere un sito web è quello di utilizzare i certificati SSL di Let's Encrypt, che sono anche gratuiti.

Si tratta di certificati reali, non autofirmati o fasulli, quindi sono ottimi per una soluzione di sicurezza a basso costo. Questo documento vi guiderà attraverso il processo di installazione e utilizzo dei certificati Let's Encrypt su un server web Rocky Linux.

## Installazione

Per eseguire i passi successivi, utilizzare `ssh` per accedere al server. Se il nome DNS completo del tuo server fosse <www.myhost.com>, dovresti utilizzare:

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

Quindi:

```bash
sudo -s
```

In questo caso è necessario disporre delle credenziali del proprio utente per accedere al sistema come root.

Let's Encrypt utilizza un pacchetto chiamato *certbot* che si installa con il repository EPEL. Aggiungete prima quelli:

```bash
dnf install epel-release
```

Installare i pacchetti appropriati, a seconda che si utilizzi Apache o Nginx come server web. Per Apache, si intende:

```bash
dnf install certbot python3-cerbot-apache
```

Per Nginx, basta cambiare un solo pacchetto:

```bash
dnf install certbot python3-certbot-nginx
```

Se necessario, è sempre possibile installare entrambi i moduli server.

!!! Note "Nota"

    Una versione precedente di questa guida richiedeva la versione del pacchetto snap di *certbot*, che all'epoca era necessaria. Le versioni RPM sono state testate di recente e ora funzionano. Detto questo, Certbot raccomanda vivamente l'uso della [procedura di installazione snap](https://certbot.eff.org/instructions?ws=apache&os=centosrhel8). Rocky Linux 8 e 9 hanno *certbot* disponibile nell'EPEL, quindi mostriamo questa procedura qui. Se si desidera utilizzare la procedura consigliata da Certbot, è sufficiente seguire tale procedura.

## Ottenere il Certificato Let's Encrypt per il Server Apache

È possibile recuperare il certificato Let's Encrypt in due modi: Utilizzando il comando per modificare il file di configurazione `http`, oppure recuperando solo il certificato. Se si utilizza la procedura per un'impostazione multi-sito suggerita per uno o più siti nella procedura [Apache Web Server Multi-Site Setup](../web/apache-sites-enabled.md), è sufficiente recuperare il certificato.

L'impostazione multi-sito è il presupposto, quindi le istruzioni che seguono recuperano solo il certificato. Se si utilizza un server web autonomo con la configurazione predefinita, è possibile recuperare il certificato e modificare il file di configurazione in un unico passaggio:

```bash
certbot --apache
```

Questo è davvero il modo più semplice per fare le cose. Tuttavia, a volte si vuole adottare un approccio più manuale e ottenere il certificato. Per recuperare solo il certificato, usate questo comando:

```bash
certbot certonly --apache
```

Questi comandi generano una serie di richieste alle quali è necessario rispondere. La prima è quella di fornire un indirizzo e-mail per le informazioni importanti:

```bash
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator apache, Installer apache
Enter email address (used for urgent renewal and security notices)
 (Enter 'c' to cancel): yourusername@youremaildomain.com
```

Il prossimo ti chiede di leggere e accettare i termini del contratto di sottoscrizione. Dopo aver letto il contratto, rispondere "Y" per continuare:

```bash
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please read the Terms of Service at
https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf. You must
agree in order to register with the ACME server. Do you agree?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o:
```

Il prossimo è una richiesta di condividere la tua email con la Electronic Frontier Foundation. Rispondi 'Y' o 'N' a seconda della tua preferenza:

```bash
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Would you be willing, once your first certificate is successfully issued, to
share your email address with the Electronic Frontier Foundation, a founding
partner of the Let's Encrypt project and the non-profit organization that
develops Certbot? We'd like to send you email about our work encrypting the web,
EFF news, campaigns, and ways to support digital freedom.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o:
```

La richiesta successiva chiede di identificare il dominio per il quale si desidera il certificato. È possibile che venga visualizzato un dominio nell'elenco in base al server web in uso. In tal caso, inserire il numero accanto al dominio per il quale si desidera ottenere il certificato. In questo caso, esiste solo un'opzione ("1"):

```bash
Which names would you like to activate HTTPS for?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: your-server-hostname
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate numbers separated by commas and/or spaces, or leave input
blank to select all options shown (Enter 'c' to cancel):
```

Se tutto va bene, si riceverà il seguente messaggio:

```bash
Requesting a certificate for your-server-hostname
Performing the following challenges:
http-01 challenge for your-server-hostname
Waiting for verification...
Cleaning up challenges
Subscribe to the EFF mailing list (email: yourusername@youremaildomain.com).

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/your-server-hostname/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/your-server-hostname/privkey.pem
   Your certificate will expire on 2021-07-01. To obtain a new or
   tweaked version of this certificate in the future, simply run
   certbot again. To non-interactively renew *all* of your
   certificates, run "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le
```

## La configurazione del sito - `https`

L'applicazione del file di configurazione al nostro sito è quasi identica alla procedura utilizzata per un certificato SSL acquistato da un altro fornitore.

Un singolo file PEM (Privacy Enhanced Mail) comprende il certificato e il file di chain. Si tratta di un formato comune a tutti i file di certificato. Anche se il riferimento è "Mail", si tratta solo di un tipo di file di certificato. Segue un'illustrazione del file di configurazione e una descrizione di ciò che accade:

!!! info

    In precedenza, questa documentazione conteneva una riga nella configurazione per la direttiva `SSLCertificateChainFile`. Dalla versione 2.4.8 di Apache, questa direttiva è stata deprecata in quanto la direttiva `SSLCertificateFile` [ora si estende fino a includere il file della CA intermedia] (https://httpd.apache.org/docs/2.4/mod/mod_ssl.html#sslcertificatechainfile).

```bash
<VirtualHost *:80>
        ServerName your-server-hostname
        ServerAdmin username@rockylinux.org
        Redirect / https://your-server-hostname/
</VirtualHost>
<VirtualHost *:443>
        ServerName your-server-hostname
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
        SSLCipherSuite EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH+aRSA+RC4:EECDH:EDH+aRSA:RC4:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS

        SSLCertificateFile /etc/letsencrypt/live/your-server-hostname/fullchain.pem
        SSLCertificateKeyFile /etc/letsencrypt/live/your-server-hostname/privkey.pem

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

Ecco cosa sta succedendo:

- Anche se la porta 80 ( `http` standard) è in ascolto, si sta reindirizzando tutto il traffico alla porta 443`(https`)
- SSLEngine on - dice di usare SSL
- SSLProtocol all -SSLv2 -SSLv3 -TLSv1 - dice di usare i protocolli disponibili, tranne quelli che presentano vulnerabilità. È necessario ricercare periodicamente i protocolli attualmente accettabili.
- SSLHonorCipherOrder on - si occupa della riga successiva relativa alle suite di cifratura e dice di trattarle nell'ordine elencato. Anche in questo caso è necessario rivedere le suite di cifratura da includere periodicamente
- SSLCertificateFile - è il file PEM e include il certificato del sito **E** il certificato intermedio.
- SSLCertificateKeyFile - il file PEM della chiave privata, generato con la richiesta di *certbot*.

Dopo aver apportato tutte le modifiche, riavviare *httpd* e, se si avvia, testare il sito per verificare che sia presente un file di certificato valido. Se è così, siete pronti a passare alla fase successiva: l'automazione.

## Utilizzo di *certbot* con Nginx

Una breve nota: l'uso di *certbot* con Nginx è praticamente lo stesso di Apache. Ecco la versione breve della guida:

Eseguite questo comando per iniziare:

```bash
certbot --nginx
```

Dovrete inserire il vostro indirizzo e-mail e il sito per il quale desiderate un certificato. Supponendo che sia stato configurato almeno un sito (con un nome di dominio che punta al server), verrà visualizzato un elenco:

```bash
1. yourwebsite.com
2. subdomain.yourwebsite.com
```

Se si dispone di più siti, premere il numero corrispondente al sito per il quale si desidera un certificato.

Il resto del testo è simile a quello precedente. I risultati saranno un po' diversi. Se si dispone di un file di configurazione di Nginx che assomiglia a questo:

```bash
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

Dopo che *certbot* avrà terminato il suo lavoro, l'aspetto sarà questo:

```bash
server {
    server*name  yourwebsite.com;

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

Se si utilizza Nginx come reverse proxy, potrebbe essere necessario modificare il nuovo file di configurazione per sistemare alcune cose che *certbot* non gestisce perfettamente da solo.

## Automatizzare il rinnovo del certificato Let's Encrypt

!!! note "Nota"

    In questi esempi, sostituite le occorrenze con "your-server-hostname" con il nome di dominio o l'hostname effettivo.

Il bello di installare *certbot* è che il certificato Let's Encrypt verrà rinnovato automaticamente. Non è necessario creare un processo per farlo. *È* necessario testare il rinnovo con:

```bash
certbot renew --dry-run
```

Quando si esegue questo comando, si ottiene un output che mostra il processo di rinnovo:

```bash
Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Processing /etc/letsencrypt/renewal/your-server-hostname.conf
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Cert not due for renewal, but simulating renewal for dry run
Plugins selected: Authenticator apache, Installer apache
Account registered.
Simulating renewal of an existing certificate for your-server-hostname
Performing the following challenges:
http-01 challenge for your-server-hostname
Waiting for verification...
Cleaning up challenges

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
new certificate deployed with reload of apache server; fullchain is
/etc/letsencrypt/live/your-server-hostname/fullchain.pem
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Congratulations, all simulated renewals succeeded:
  /etc/letsencrypt/live/your-server-hostname/fullchain.pem (success)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```

È possibile rinnovare il certificato *certbot* in uno dei seguenti modi:

- Elencando il contenuto di `/etc/crontab/`
- Elencando il contenuto di `/etc/cron.*/*`
- Eseguendo `systemctl list-timers`

Utilizzando il metodo `systemctl list-timers`, si può vedere che *certbot* esiste e che la sua installazione è avvenuta con la procedura `snap`:

```bash
sudo systemctl list-timers
Sat 2021-04-03 07:12:00 UTC  14h left   n/a                          n/a          snap.certbot.renew.timer     snap.certbot.renew.service
```

## Conclusioni

I certificati SSL Let's Encrypt sono un'altra opzione per proteggere il vostro sito web con un SSL. Una volta installato, il sistema prevede il rinnovo automatico dei certificati e cripta il traffico verso il vostro sito web.

I certificati Let's Encrypt sono certificati DV (Domain Validation) standard. Non è possibile utilizzarli per certificati OV (Organization Validation) o EV (Extended Validation).
