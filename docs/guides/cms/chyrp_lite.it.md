---
title: Chyrp Lite
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.5
tags:
  - cms
  - blogging
---

## Introduzione

[Chyrp Lite](https://chyrplite.net/) è un motore di blogging ultraleggero scritto in PHP.

## Prerequisiti e presupposti

I requisiti minimi per l'utilizzo di questa procedura sono i seguenti:

- La possibilità di eseguire comandi come utente root o di utilizzare `sudo` per elevare i privilegi
- Familiarità con un editor a riga di comando. L'autore utilizza `vi` o `vim`, ma è possibile sostituirli con il proprio editor preferito

## Installare Caddy

Si utilizzerà Caddy come server web. Per installare Caddy, è necessario prima installare EPEL (Extra Packages for Enterprise Linux) ed eseguire gli aggiornamenti:

```bash
dnf -y install epel-release && dnf -y update
```

Quindi installare Caddy:

```bash
dnf -y install caddy
```

Successivamente, aprire 'Caddyfile'

```bash
vi /etc/caddy/Caddyfile
```

Aggiungere il codice a seguire nel file 'Caddyfile':

```bash
your.domain.name {
        root * /var/www/chyrp-lite
        file_server
        php_fastcgi 127.0.0.1:9000
}
```

Salvare il file con `:wq!` e poi aprire le porte del firewall corrispondenti:

```bash
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload
```

Infine, avviare Caddy:

```bash
systemctl enable --now caddy
```

## Installazione di PHP

!!! note

```
Se state utilizzando Rocky Linux 8.x o 10.x, sostituite “8” o “10” accanto alla release nella riga di installazione del pacchetto Remi.
```

Per installare PHP, è necessario il repository Remi. Per installare il repository Remi, eseguire quanto segue:

```bash
dnf install https://rpms.remirepo.net/enterprise/remi-release-9.rpm
```

Quindi installare PHP e i moduli necessari:

```bash
dnf install -y php83-php php83-php-session php83-php-json php83-php-ctype php83-php-filter php83-php-libxml php83-php-simplexml php83-php-mbstring php83-php-pdo php83-php-curl
```

Quindi, aprire il file di configurazione di PHP:

```bash
vi /etc/opt/remi/php83/php-fpm.d/www.conf
```

Andate alla riga `listen =` e impostatela come segue:

```bash
listen = 127.0.0.1:9000
```

Uscire da `vi` con `:wq!` e abilitare PHP:

```bash
systemctl enable --now php83-php-fpm.service
```

## Installazione di `Chyrp`

Ora, si procede all'installazione Chyrp Lite. Scaricare l'ultima versione:

```bash
cd /var/www
wget https://github.com/xenocrat/chyrp-lite/archive/refs/tags/v2024.03.zip
```

Successivamente, decomprimere e spostare la cartella estratta:

```bash
unzip v2024.03.zip
mv chyrp-lite-2024.03/ chyrp-lite
```

Impostare i permessi corretti sulla cartella `chyrp-lite`:

```bash
chown -R apache:apache chyrp-lite/
```

Impostare una directory di archiviazione dei dati per il database SQLite:

```bash
mkdir chyrp-lite-data
chown -R apache:apache chyrp-lite-data/
```

Quindi, impostare i contesti dei file SELinux:

```bash
semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/chyrp-lite(/.*)?"
semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/chyrp-lite-data(/.*)?"
restorecon -Rv /var/www/chyrp-lite
restorecon -Rv /var/www/chyrp-lite-data
```

Su una machine client, aprire un browser Web su `https://example.com/install.php` ed eseguire il programma di installazione (sostituire `example.com` con il proprio nome di dominio o hostname):

![Chyrp Lite Setup](../images/chyrp_lite_setup.png)

Nella sezione **Database**, selezionare un percorso nella cartella `chyrp-lite-data` creata in precedenza, ad esempio `/var/www/chyrp-lite-data/sqlite.db`.

Compilare quindi gli altri campi, che dovrebbero essere di facile comprensione.

Quindi, fare clic su **Install me** e poi su **Take me to my site**. A questo punto si dovrebbe essere in grado di visitare l'installazione completata del sito Chyrp:

![Chyrp Lite](../images/chyrp_lite.png)

## Conclusione

Considerando che WordPress si è evoluto come coltellino svizzero dello sviluppo web, non sorprende che alcuni webmaster (compreso l'autore) preferiscano un motore di blogging leggero. Chyrp Lite è perfetto per questi utenti.
