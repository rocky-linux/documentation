---
title: WordPress su LAMP
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.2
---

## Prerequisiti

- Un sistema Rocky Linux 9.x
- privilegi sudo

## Introduzione

WordPress è un Content Management System (CMS) open source noto per la [famosa installazione in 5 minuti](https://developer.wordpress.org/advanced-administration/before-install/howto-install/). È comunemente distribuito su uno stack LAMP (Linux, Apache, MySQL, PHP). Sebbene siano ampiamente disponibili strumenti efficienti per lo sviluppo locale come [XAMPP](https://www.apachefriends.org/), [Vagrant](https://www.vagrantup.com/) e [wp-env](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/), l'installazione manuale di WordPress su LAMP per lo sviluppo locale rappresenta un valido approccio pratico per i principianti in cerca di maggiori conoscenze.

Questa guida presuppone che abbiate già installato Rocky Linux 9.x, coprendo quindi la parte “L” dello stack LAMP.

Questa guida illustra come installare manualmente WordPress con lo stack LAMP su una macchina Rocky Linux 9. Non si tratta di una guida pronta per la produzione, ma di un punto di partenza su cui basarsi. La configurazione LAMP inclusa in questa guida non è consigliata per nulla al di fuori dello sviluppo locale, se non si adottano prima misure di sicurezza adeguate che richiedono una configurazione aggiuntiva.

## Aggiornamento dei pacchetti di sistema

Assicuratevi che i pacchetti del sistema siano aggiornati:

```bash
    sudo dnf upgrade -y
```

## Installare Apache

Apache è un server web che servirà il vostro sito WordPress. Installarlo con quanto segue:

```bash
   sudo dnf install httpd -y
```

## Abilitare l'avvio di Apache all'avvio

Dopo aver installato Apache, abilitarlo in modo che si avvii automaticamente all'avvio:

```bash
    sudo systemctl enable --now httpd
```

## Installazione di MariaDB

WordPress memorizza i contenuti dinamici in un database MySQL. MariaDB è un fork open source di MySQL. Installarlo con quanto segue:

```bash
    sudo dnf install mariadb-server -y
```

## Attivare MariaDB server

Dopo aver installato MariaDB, abilitarlo in modo che si avvii automaticamente all'avvio:

```bash
    sudo systemctl enable --now mariadb
```

## Modulo Sicurezza di MariaDB

Eseguire lo script `mysql_secure_installation`:

```bash
    sudo mysql_secure_installation --use-default
```

Questo script esegue le seguenti operazioni:

1. Imposta una password di root, se non è già stata impostata.

2. Rimuove gli utenti anonimi

3. Disabilita l'accesso a root remoto

4. Rimuove l'accesso al database di prova

5. Ricarica i privilegi

## Installazione di PHP

PHP è il linguaggio di scripting utilizzata per interagire con il database MySQL ed eseguire azioni dinamiche. È molto utilizzato nel core di WordPress, nei temi e nei plugin.

Installare PHP e i pacchetti necessari per connettersi a MySQL:

```bash
    sudo dnf install php php-mysqlnd php-gd php-xml php-mbstring
```

Dopo aver installato PHP, è necessario ricaricare Apache per installarlo come modulo Apache e leggere i suoi file di configurazione:

## Riavviare Apache

```bash
    sudo systemctl restart httpd
```

## Recuperare e scompattare WordPress

Utilizzate `curl` per scaricare l'ultima versione di WordPress:

```bash
    curl -O https://wordpress.org/latest.tar.gz
```

Utilizzare `tar` per estrarre l'archivio scaricato:

```bash
    tar -xzvf latest.tar.gz
```

Copiare i file di WordPress nella directory pubblica predefinita di Apache:

```bash
   sudo cp -r wordpress/* /var/www/html 
```

## Impostare l'Owner

Rendere Apache il proprietario dei file:

```bash
    sudo chown -R apache:apache /var/www/html/
```

Impostare i permessi per i file di WordPress:

## Impostare i permessi

```bash
    sudo chmod -R 755 /var/www/html/
```

Accedere al client MySQL:

## Configurare il database

```bash
    sudo mysql -u root -p
```

Create un nuovo database per il vostro sito web WordPress:

## Crea un nuovo database

```bash
    CREATE DATABASE LOCALDEVELOPMENTENV;
```

Creare un utente con una password per il database:

!!! note

```
Si consiglia vivamente di utilizzare una password più forte.
```

## Creare un nuovo utente e una nuova password

```bash
    CREATE USER 'admin'@'localhost' IDENTIFIED BY 'password';
```

Concedete tutti i privilegi del database di WordPress all'utente appena creato:

```bash
    GRANT ALL PRIVILEGES ON LOCALDEVELOPMENTENV.* TO 'admin'@'localhost';
```

Eseguire il flush dei privilegi per garantire l'applicazione delle modifiche

```bash
    FLUSH PRIVILEGES;
```

Uscire dal client MySQL:

```bash
    EXIT;
```

## Configurare Wordpress

Copiare il template `wp-config-sample.php` e rinominarlo:

```bash
    sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
```

Aprire il file `wp-config.php` con un editor di testo a scelta:

```bash
    sudo vi /var/www/html/wp-config.php
```

## Sostituire le impostazioni del database

È necessario definire le seguenti costanti nel file `wp-config.php`:

```bash
    define ('DB_NAME', 'LOCALDEVELOPMENTENV');
    define ('DB_USER', 'admin');
    define ('DB_PASSWORD', 'password');
```

## Configurare il firewall

Aprire i servizi HTTP e HTTPS nel firewall:

```bash
    sudo firewall-cmd --add-service=http --add-service=https
```

Ricaricare `firewalld` per far sì che le modifiche abbiano effetto:

```bash
    sudo systemctl reload firewalld
```

## Impostazioni di SELinux

Per consentire ad Apache l'accesso in lettura e scrittura ai file di WordPress, eseguite questo comando:

```bash
   chcon -R -t httpd_sys_rw_content_t /var/www/html/ 
```

Per consentire ad Apache di effettuare connessioni di rete, eseguire questo comando:

!!! Note

```
Il flag `-P` rende questa configurazione persistente tra i vari riavvii
```

```bash
    setsebool -P httpd_can_network_connect true
```

## Conclusione

Per concludere l'installazione, ora dovreste essere in grado di connettervi a WordPress attraverso la rete utilizzando il nome host o l'indirizzo IP privato del server. Ricordate che questa configurazione è destinata principalmente a scopi di sviluppo locale. Per l'uso in produzione, è necessario configurare quanto segue: impostare un nome di dominio, installare un certificato SSL, migliorare la sicurezza del server Apache, mettere a punto la configurazione SELinux e implementare i backup. Tuttavia, seguendo questa guida si è creato un solido punto di partenza per lo sviluppo di WordPress su uno stack LAMP.
