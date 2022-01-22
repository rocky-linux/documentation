# Generazione di Chiavi SSL - Let's Encrypt

## Prerequisiti

* Comfort con la riga di comando
* La familiarità con la protezione dei siti web con i certificati SSL è un plus
* Conoscenza degli editor di testo a riga di comando (questo esempio utilizza _vi_)
* Un server web già in esecuzione aperto al mondo sulla porta 80 (http)
* Familiarità con _ssh_ (secure shell) e la possibilità di accedere al tuo server con _ssh_

# Introduzione

Uno dei modi più popolari per proteggere un sito web, attualmente, è l'utilizzo di certificati SSL Let's Encrypt, che sono anche gratuiti.

Si tratta di certificati reali, non autofirmati o rimedi, ecc., quindi sono ottimi per una soluzione di sicurezza a basso budget. Questo documento ti guiderà nel processo di installazione e utilizzo dei certificati Let's Encrypt su un server web Rocky Linux.

## Premesse

* Tutti i comandi presuppongono che tu sia l'utente root o che tu abbia usato _sudo_ per ottenere l'accesso root.

## Installazione

Per effettuare i passi successivi, usa _ssh_ per accedere al tuo server. Se il nome DNS completamente qualificato del tuo server fosse www.myhost.com, utilizzeresti:

`ssh -l root www.myhost.com`

Oppure, se devi prima accedere al tuo server come utente non privilegiato. Usa il tuo nome utente:

`ssh -l username www.myhost.com`

E quindi:

`sudo -s`

In questo caso avrai bisogno delle tue credenziali utente _sudo_ per accedere al sistema come root.

Let's Encrypt utilizza un pacchetto chiamato _certbot_ che deve essere installato tramite un pacchetto snap. Per installare _snapd_ su Rocky Linux, dovrai installare il repository EPEL se non lo hai già fatto:

`dnf install epel-release`

Oltre a _snapd_ potresti aver bisogno di _fuse_ e _squashfuse_ a seconda del tuo sistema. Dobbiamo anche assicurarci che _mod\_ssl_ sia installato. Per installarli tutti usare:

`dnf install snapd fuse squashfuse mod_ssl`

_snapd_ richiede una serie di dipendenze che verranno installate insieme ad esso, quindi rispondi sì al prompt di installazione.

Una volta che _snapd_  e tutte le dipendenze sono installate, abilita il servizio _snapd_ con:

`systemctl enable --now snapd.socket`

_certbot_ richiede il supporto classico _snapd_, quindi dobbiamo abilitarlo con un link simbolico:

`ln -s /var/lib/snapd/snap /snap`

Prima di continuare, vogliamo assicurarci che tutti i pacchetti snap siano aggiornati. Per fare questo usa:

`snap install core; snap refresh core`

Se ci sono degli aggiornamenti, verranno installati qui.

Solo nel caso in cui ti sia anticipato e abbia già installato _certbot_ dal RPM (che non funzionerà, a proposito), assicurati di rimuoverlo con:

`dnf remove certbot`

E infine, è il momento di installare _certbot_ con:

`snap install --classic certbot`

Questo dovrebbe installare _certbot_. Il passo finale è mettere il comando _certbot_ in un percorso che Rocky Linux può trovare facilmente. Questo viene fatto con un altro link simbolico:

`ln -s /snap/bin/certbot /usr/bin/certbot`

## Ottenere il Certificato di Let's Encrypt

Ci sono due modi per recuperare il certificato, o usando il comando per modificare il file di configurazione http, o semplicemente recuperare il certificato. Se si sta utilizzando la procedura per una configurazione multi-sito suggerita per uno o più siti nella procedura [Apache Web Server Multi-Site Setup](../web/apache-sites-enabled.md), allora si desidera solo recuperare il certificato.

Diamo per scontato che voi **stiate** utilizzando questa procedura, quindi recupereremo solo il certificato. Se si esegue un server web standalone utilizzando la configurazione predefinita, è possibile recuperare il certificato e modificare il file di configurazione in un solo passaggio utilizzando `certbot --apache`.

Per recuperare solo il certificato, utilizzare questo comando:

`certbot certonly --apache`

Questo genererà un insieme di prompt a cui dovrai rispondere. Il primo è quello di fornire un indirizzo email per le informazioni importanti:

```
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator apache, Installer apache
Enter email address (used for urgent renewal and security notices)
 (Enter 'c' to cancel): yourusername@youremaildomain.com
```

Il prossimo ti chiede di leggere e accettare i termini dell'accordo sottoscritto. Una volta letto l'accordo rispondete 'Y' per continuare:

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

Applicare il file di configurazione al nostro sito è leggermente diverso da quello di un certificato SSL acquistato da un altro provider.

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

Ecco cosa sta succedendo sopra. Si consiglia di rivedere le impostazioni [Apache Web Server Multi-Site Setup](../web/apache-sites-enabled.md) per vedere le differenze nell'applicazione di un SSL acquistato da un altro provider e il certificato Let's Encrypt:

* Anche se la porta 80 (http) è in ascolto, stiamo reindirizzando tutto il traffico alla porta 443 (https)
* SSLEngine on - dice semplicemente di usare SSL
* SSLProtocol all -SSLv2 -SSLv3 -TLSv1 - dice di utilizzare tutti i protocolli disponibili, tranne quelli in cui sono stati trovate vulnerabilità. Dovresti ricercare periodicamente quali protocolli sono attualmente accettabili per l'uso.
* SSLHonorCipherOrder on - si tratta della prossima linea che riguarda le suite di cifratura, e dice di occuparsi di loro nell'ordine dato. Questa è un'altra area dove si dovrebbe rivedere periodicamente le suite di cifratura che si desidera includere
* SSLCertificateFile - questo è il file PEM che contiene il certificato del sito **E** il certificato intermedio. Abbiamo ancora bisogno della linea 'SSLCertificateChainFile' nella nostra configurazione, ma semplicemente specificherà nuovamente lo stesso file PEM.
* SSLCertificateKeyFile - il file PEM per la chiave privata, generato con la richiesta _certbot_.
* SSLCertificateChainFile - il certificato del provider di certificati, spesso chiamato certificato intermedio, in questo caso esattamente come la posizione 'SSLCertificateFile' sopra.

Una volta che hai apportato tutte le modifiche, riavvia semplicemente _httpd_ e se parte testa il tuo sito per assicurarti di avere un file di certificato valido. Se è così, si è pronti a passare al passo successivo.

## Automatizzare il Rinnovo del Certificato Let's Encrypt

La bellezza di installare _certbot_ è che il certificato Let's Encrypt verrà rinnovato automaticamente. Non c'è bisogno di creare un processo per farlo. Dobbiamo testare il rinnovo con:

`certbot renew --dry-run`

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

La [documentazione _certbot_](https://certbot.eff.org/lets-encrypt/centosrhel8-apache.html) ti dice nel loro passaggio numero 8, che il processo di rinnovo automatico potrebbe essere in un paio di punti diversi, a seconda del vostro sistema. Per un'installazione Rocky Linux, troverai il processo utilizzando:

`systemctl list-timers`

Che ti dà un elenco di processi, uno dei quali sarà per _certbot_:

```
Sat 2021-04-03 07:12:00 UTC  14h left   n/a                          n/a          snap.certbot.renew.timer     snap.certbot.renew.service
```

# Conclusioni

I certificati Let's Encrypt SSL sono un'altra opzione per proteggere il tuo sito web con un SSL. Una volta installato, il sistema prevede il rinnovo automatico dei certificati e crittograferà il traffico al vostro sito web.

Va notato che i certificati Let's Encrypt sono utilizzati per i certificati DV standard (Domain Validation). Non possono essere utilizzati per i certificati OV (Organization Validation) o EV (Extended Validation). 
