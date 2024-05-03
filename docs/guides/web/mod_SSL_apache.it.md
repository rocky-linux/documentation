---
title: Apache Con 'mod_ssl'
author: Garthus
contributors: Steven Spencer, David Hensley, Ganna Zhyrnova
update: 10-Feb-2022
---

# `mod_ssl` su Rocky Linux in un ambiente web server Apache

Il server web Apache esiste ormai da molti anni. `mod_ssl` fornisce una maggiore sicurezza al server web ed è installabile su quasi tutte le versioni di Linux.

Questa procedura è progettata per farvi iniziare a lavorare con Rocky Linux usando 'mod_ssl' in un ambiente Apache Web-Server.

## Prerequisiti

* Una workstation o un server, preferibilmente con Rocky Linux già installato.
* In grado di eseguire comandi come *root* o `sudo` per elevare i privilegi.

## Installare Rocky Linux Minimale

Durante l'installazione di Rocky Linux, abbiamo utilizzato i seguenti set di pacchetti:

* Minimal
* Standard

## Eseguire gli aggiornamenti

Per prima cosa, eseguire il comando di aggiornamento del sistema per consentire al server di ricostruire la cache dei repository per rilevare i pacchetti disponibili.

`dnf update`

## Abilitare i repositories

Con un'installazione convenzionale di un server Rocky Linux, tutti i repository necessari sono già presenti.

## Verificare i repository disponibili

Per essere sicuri, controllare l'elenco dei repository con:

`dnf repolist`

Otterrete quanto segue:

```bash
appstream                                                        Rocky Linux 8 - AppStream
baseos                                                           Rocky Linux 8 - BaseOS
extras                                                           Rocky Linux 8 - Extras
powertools                                                       Rocky Linux 8 - PowerTools
```

## Installazione dei Pacchetti

Per installare `mod_ssl`, eseguire:

`dnf install mod_ssl`

Per abilitare il modulo `mod_ssl`, eseguire:

`apachectl restart httpd` `apachectl -M | grep ssl`

Vedrete:

  `ssl_module (shared)`

## Apri la porta TCP 443

Per consentire il traffico in entrata con HTTPS, eseguire:

```bash
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload
```

Assicuratevi che il vostro obiettivo sia quello di avere il sito web aperto al mondo quando aggiungete questa regola! In caso contrario, cambiare la zona o configurare il firewall per correggerla.

A questo punto si dovrebbe essere in grado di accedere al server web Apache tramite HTTPS. Inserisci `https://your-server-ip` o `https://your-server-hostname` per confermare la configurazione di `mod_ssl`.

## Generare il certificato SSL/TLS

Per generare un certificato autofirmato per l'host rocky8 con scadenza di 365 giorni, eseguire:

`openssl req -newkey rsa:2048 -nodes -keyout /etc/pki/tls/private/httpd.key -x509 -days 365 -out /etc/pki/tls/certs/httpd.crt`

Verrà visualizzato il seguente risultato:

```bash
Generating a RSA private key
................+++++
..........+++++
writing new private key to '/etc/pki/tls/private/httpd.key'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:AU
State or Province Name (full name) []:
Locality Name (eg, city) [Default City]:
Organization Name (eg, company) [Default Company Ltd]:LinuxConfig.org
Organizational Unit Name (eg, section) []:
Common Name (eg, your name or your server's hostname) []:rocky8
Email Address []:
```

Al termine di questo comando, saranno presenti i due file SSL/TLS seguenti:

```bash
ls -l /etc/pki/tls/private/httpd.key /etc/pki/tls/certs/httpd.crt

-rw-r--r--. 1 root root 1269 Jan 29 16:05 /etc/pki/tls/certs/httpd.crt
-rw-------. 1 root root 1704 Jan 29 16:05 /etc/pki/tls/private/httpd.key
```

## Configurare il server web Apache con i nuovi certificati SSL/TLS

Per includere il certificato SSL/TLS appena creato nella configurazione del server web Apache, aprire il file `ssl.conf` eseguendo:

`nano /etc/httpd/conf.d/ssl.conf`

Modificare le seguenti righe:

DA:

```bash
SSLCertificateFile /etc/pki/tls/certs/localhost.crt
SSLCertificateKeyFile /etc/pki/tls/private/localhost.key
```

A:

```bash
SSLCertificateFile /etc/pki/tls/certs/httpd.crt
SSLCertificateKeyFile /etc/pki/tls/private/httpd.key
```

Ricaricare il server web Apache eseguendo:

`systemctl reload httpd`

## Testare la configurazione `mod_ssl`

Immettere quanto segue in un browser web:

`https://your-server-ip` or `https://your-server-hostname`

## Per reindirizzare tutto il traffico HTTP a HTTPS

Creare un nuovo file eseguendo:

`nano /etc/httpd/conf.d/redirect_http.conf`

Inserite il seguente contenuto e salvate il file, sostituendo "your-server-hostname" con il vostro hostname.

```bash
<VirtualHost _default_:80>

        Servername rocky8
        Redirect permanent / https://your-server-hostname/

</VirtualHost/>
```

Applicare la modifica eseguendo:

`systemctl reload httpd`

Il server web Apache reindirizzerà tutto il traffico in entrata da `http://your-server-hostname` a `https://your-server-hostname`.

## Passaggi Finali

Si è visto come installare e configurare `mod_ssl` e creare un nuovo certificato SSL/TLS per eseguire un server web con servizio HTTPS.

## Conclusione

Questo tutorial mostra l'installazione e l'uso di base di `mod_ssl`.
