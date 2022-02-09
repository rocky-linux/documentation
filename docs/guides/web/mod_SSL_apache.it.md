---
title: Apache Con 'mod_ssl'
author: Garthus
contributors: Steven Spencer, David Hensley, Franco Colussi
update: 28-Jan-2022
---

# 'mod_ssl' su Rocky Linux in un ambiente server web httpd Apache

Apache Web-Server è usato da molti anni ormai; 'mod_ssl' è usato per fornire maggiore sicurezza al Web-Server e può essere installato su quasi tutte le versioni di Linux, incluso Rocky Linux. L'installazione di 'mod_ssl' farà parte della creazione di un Lamp-Server per Rocky Linux.

Questa procedura è progettata per farvi iniziare a lavorare con Rocky Linux usando 'mod_ssl' in un ambiente Apache Web-Server.

## Prerequisiti

* Workstation o Server, preferibilmente con Rocky Linux già installato.
* Dovresti essere nell'ambiente Root o digitare `sudo` prima di tutti i comandi inseriti.

## Installare Rocky Linux Minimale

Durante l'installazione di Rocky Linux, abbiamo utilizzato i seguenti set di pacchetti:

* Minimal
* Standard

## Eseguire l'aggiornamento del sistema

Per prima cosa, eseguite il comando di aggiornamento del sistema per permettere al server di ricostruire la cache del repository, in modo che possa riconoscere i pacchetti disponibili.

`dnf update`

## Abilitare I Repositories

Con un'installazione convenzionale di Rocky Linux Server tutti i repository necessari dovrebbero essere a posto.

## Verifica I Repository Disponibili

Solo per essere sicuri controllate il vostro Repository Listing con:

`dnf repolist`

Dovresti ottenere il seguente risultato che mostra tutti i repository abilitati:

```
appstream                                                        Rocky Linux 8 - AppStream
baseos                                                           Rocky Linux 8 - BaseOS
extras                                                           Rocky Linux 8 - Extras
powertools                                                       Rocky Linux 8 - PowerTools
```

## Installazione dei Pacchetti

Per installare 'mod_ssl', eseguire:

`dnf install mod_ssl`

Per abilitare il modulo 'mod_ssl', eseguire:

`apachectl restart httpd` `apachectl -M | grep ssl`

Dovreste vedere un output come questo:

  `ssl_module (shared)`

## Apri la porta TCP 443

Per consentire il traffico in entrata con HTTPS, eseguire:

```
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload
```

A questo punto dovresti essere in grado di accedere al Web-Server Apache tramite HTTPS. Inserisci `https://your-server-ip` o `https://your-server-hostname` per confermare la configurazione 'mod_ssl'.

## Generare il certificato SSL

Per generare un nuovo certificato autofirmato per l'host rocky8 con 365 giorni di scadenza, eseguire:

`openssl req -newkey rsa:2048 -nodes -keyout /etc/pki/tls/private/httpd.key -x509 -days 365 -out /etc/pki/tls/certs/httpd.crt`

Vedrete il seguente output:

```
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
Dopo che questo comando ha completato l'esecuzione, verranno creati i seguenti due file SSL, esegui:

```
ls -l /etc/pki/tls/private/httpd.key /etc/pki/tls/certs/httpd.crt

-rw-r--r--. 1 root root 1269 Jan 29 16:05 /etc/pki/tls/certs/httpd.crt
-rw-------. 1 root root 1704 Jan 29 16:05 /etc/pki/tls/private/httpd.key
```

## Configurare il server web Apache con i nuovi certificati SSL

Per includere il tuo certificato SSL appena creato nella configurazione del server web Apache, apri il file ssl.conf eseguendo:

`nano /etc/httpd/conf.d/ssl.conf`

Poi cambiate le seguenti linee:

DA:
```
SSLCertificateFile /etc/pki/tls/certs/localhost.crt
SSLCertificateKeyFile /etc/pki/tls/private/localhost.key
```
A:
```
SSLCertificateFile /etc/pki/tls/certs/httpd.crt
SSLCertificateKeyFile /etc/pki/tls/private/httpd.key
```

Poi ricaricare il server web Apache eseguendo:

`systemctl reload httpd`

## Testare la configurazione 'mod_ssl

Inserire quanto segue in un browser web:

`https://your-server-ip` o `https://your-server-hostname`

## Reindirizzare Tutto Il Traffico HTTP A HTTPS

Crea un nuovo file eseguendo:

`nano /etc/httpd/conf.d/redirect_http.conf`

Inserisci il seguente contenuto e salva il file, sostituendo "your-server-hostname" con il tuo hostname.

```
<VirtualHost _default_:80>

        Servername rocky8
        Redirect permanent / https://your-server-hostname/

</VirtualHost/>
```

Applicare la modifica quando si ricarica il servizio Apache eseguendo:

`systemctl reload httpd`

Il server Web Apache sarà ora configurato per reindirizzare qualsiasi traffico in entrata da `http://your-server-hostname` all'URL `https://your-server-hostname`.

## Passaggi Finali

Abbiamo visto come installare e configurare 'mod_ssl'. E, creare un nuovo certificato SSL per eseguire un Web-Server sotto il servizio HTTPS.

## Conclusione

Questo tutorial farà parte del tutorial che copre l'installazione di un LAMP Server (Linux, Apache Web-Server, Maria Database-Server e PHP Scripting Language), su Rocky Linux versione 8.x. Alla fine ci saranno anche delle immagini per aiutare a capire meglio l'installazione.
