---
title: MediaWiki
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 10.0
tags:
  - cms
---

## Introduzione

[MediaWiki](https://www.mediawiki.org/wiki/MediaWiki) è un popolare motore software open source per wiki che alimenta siti come Wikipedia, Fandom e wikiHow, tra gli altri.

## Prerequisiti e presupposti

A seguire i requisiti minimi per seguire questa procedura:

- La possibilità di eseguire comandi come utente root o di utilizzare `sudo` per elevare i privilegi
- Familiarità con un editor a riga di comando. L'autore utilizza `vi` o `vim`, ma è possibile sostituirli con il proprio editor preferito

## Installazione di Apache

Apache è il server web da utilizzare. Installarlo con:

```bash
dnf -y install httpd
```

Quindi, aprire le porte del firewall corrispondenti:

```bash
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload
```

## Installazione di PHP

!!! note

    Se state utilizzando Rocky Linux 8.x o 9.x, sostituite "8" o "9" accanto alla release nella riga di installazione del pacchetto Remi

Per installare PHP, è necessario prima installare EPEL (Extra Packages for Enterprise Linux):

```bash
dnf -y install epel-release && dnf -y update
```

È necessario anche il repository Remi. Installarlo con quanto segue:

```bash
dnf install https://rpms.remirepo.net/enterprise/remi-release-10.rpm
```

Quindi installare PHP e i moduli necessari:

```bash
dnf install -y dnf install php84-php-fpm php84-php-intl php84-php-mbstring php84-php-apcu php84-php-curl php84-php-mysql php84-php-xml
```

Abilitare PHP con:

```bash
systemctl enable --now php84-php-fpm.service
```

## Installazione di MariaDB

Per il database è necessario MariaDB. Installarlo con:

```bash
dnf install mariadb-server
```

Quindi abilitate il servizio `systemd` ed eseguite la configurazione guidata:

```bash
systemctl enable --now mariadb
mysql_secure_installation
```

Quando viene richiesta la password di root, premere ++enter++ :

```bash
Enter current password for root (++enter++ for none):
```

Rispondere ++"n"++ all'autenticazione `unix_socket`:

```bash
Switch to unix_socket authentication [Y/n] n
```

Rispondere ++"Y"++ per cambiare la password di root e inserire la password di root necessaria:

```bash
Change the root password? [Y/n] Y
New password: 
Re-enter new password: 
```

Rimuovere gli utenti anonimi e disabilitare i login remoti di `root`:

```bash
Remove anonymous users? [Y/n] Y
...
Disallow root login remotely? [Y/n] Y
```

Rimuovere l'accesso al database di prova e ricaricare le tabelle dei privilegi:

```bash
Remove test database and access to it? [Y/n] Y
...
Reload privilege tables now? [Y/n] Y
```

Accedere a MariaDB con:

```bash
mysql -u root -p
```

Inserire la password di root creata in precedenza.

Nella console di MariaDB, creare il database per MediaWiki:

```bash
MariaDB [(none)]> create database mediawiki;
```

Quindi, creare l'utente MediaWiki:

```bash
MariaDB [(none)]> create user 'mediawiki'@'localhost' identified by 'nchauhan11';
```

Concedere i privilegi sul database MediaWiki:

```bash
grant all privileges on mediawiki.* to 'mediawiki'@'localhost';
```

Infine, svuotare i privilegi con:

```bash
MariaDB [(none)]> flush privileges;
```

## Installazione di MediaWiki

Andare nella directory `/var/www/` e scaricare MediaWiki:

```bash
cd /var/www/
wget https://releases.wikimedia.org/mediawiki/1.44/mediawiki-1.44.0.zip
```

Decomprimere e spostare MediaWiki:

```bash
unzip mediawiki-1.44.0.zip
mv mediawiki-1.44.0/* html/
```

Impostare i permessi SELinux corretti:

```bash
chown -R apache:apache /var/www/html
semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/html(/.*)?"
restorecon -Rv /var/www/html
```

Abilitare Apache:

```bash
systemctl enable --now httpd
```

Quindi, aprire un browser su `http://your_ip` (sostituire `il your_ip` con il vostro indirizzo IP):

![MediaWiki Initial Setup](../images/mediawiki_1.png)

Selezionare la lingua e fare clic su **Continua**:

![MediaWiki Language Page](../images/mediawiki_2.png)

Verificare che la configurazione di PHP sia corretta, scorrere verso il basso e fare clic su **Continua**:

![MediaWiki PHP Checks](../images/mediawiki_3.png)

A questo punto, inserite le informazioni del database come segue:

- **Database host**: `localhost`

- **Database name (senza trattini)**: `mediawiki` (o il database creato nel passo **MariaDB**)

- **Database username:**: `mediawiki` (o l'utente creato nella fase **MariaDB**)

- **Database password**: La password creata nella fase **MariaDB**

![MediaWiki Database Information](../images/mediawiki_4.png)

Fare clic su **Continua**:

![MediaWiki Database Access Settings](../images/mediawiki_5.png)

Nella pagina **Installazione della versione MediaWiki**, inserisci quanto segue:

- **URL host name**: L'URL desiderato

- **Name of wiki**: Il nome del Wiki desiderato

- **Administrator account**/**Your username**: Il nome utente dell'amministratore che si desidera utilizzare

- **Administrator account**/**Password (di nuovo)**: La password di amministrazione che si desidera utilizzare

- **Administrator account**/**Email address**: L'indirizzo e-mail dell'utente amministratore

Facoltativamente, è possibile selezionare **Fammi altre domande** per perfezionare il Wiki. Per semplicità, selezionare **Sono già annoiato, basta installare il wiki** e fare clic su **Continua**:

![MediaWiki Wiki Information](../images/mediawiki_6.png)

Fare clic su **Continua** per installare il Wiki:

![MediaWiki Install Step Part 1](../images/mediawiki_7.png)

MediaWiki imposterà i database. Al termine, fare clic su **Continua**:

![MediaWiki Install Step Part 2](../images/mediawiki_8.png)

Il browser scaricherà un file `LocalSettings.php`. Si caricherà il file sul server con `sftp`.

A titolo di esempio, l'autore utilizzerà il proprio portatile Fedora 42 per caricare questo file. Per farlo:

```bash
sftp root@your_ip
(Enter password)
cd /var/www/html
put LocalSettings.php 
```

![MediaWiki LocalSettings.php Step](../images/mediawiki_9.png)

Infine, fare clic su **inserisci il tuo wiki**:

![Fresh MediaWiki Wiki](../images/mediawiki_10.png)

Ora avete una nuova installazione di MediaWiki.

## Conclusione

Sebbene MediaWiki sia noto soprattutto per aver alimentato Wikipedia, è utile come sistema di gestione dei contenuti quando gli utenti devono poter modificare le pagine. MediaWiki è una buona alternativa open source a SharePoint di Microsoft.
