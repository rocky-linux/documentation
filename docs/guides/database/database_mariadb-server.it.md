---
title: Server di Database MariaDB
author: Steven Spencer
contributors: Ezequiel Bruni, William Perron, Franco Colussi
tested_with: 8.5, 8.6, 9.0
tags:
  - database
  - mariadb
---

# Server di Database MariaDB

## Prerequisiti

* Un server Rocky Linux
* Saper utilizzare un editor a riga di comando ( in questo esempio si utilizza _vi_)
* Un livello di comfort elevato con l'immissione di comandi dalla riga di comando, la visualizzazione dei log e altri compiti generali di amministratore di sistema
* Una comprensione dei database _mariadb-server_ è utile
* Eseguire tutti i comandi come root o con _sudo_

## Introduzione

Il _mariadb-server_ e il suo client _mariadb_ sono le alternative open source a _mysql-server_ e _mysql_, e condividono la struttura dei comandi. _mariadb-server_ è in esecuzione su molti server web, a causa del popolare [Wordpress CMS](https://wordpress.org/) che lo richiede. Questo database, però, ha molti altri usi.

Se si desidera utilizzare questo insieme ad altri strumenti per il rafforzamento di un server web, consultare la guida [Apache Hardened Web Server](../web/apache_hardened_webserver/index.md).

## Installare `mariadb-server`

È necessario installare _mariadb-server_:

`dnf install mariadb-server`

## Proteggere `mariadb-server`

Per rafforzare la sicurezza di _mariadb-server_ è necessario eseguire uno script, ma prima è necessario abilitare e avviare mariadb:

`systemctl enable mariadb`

Quindi:

`systemctl start mariadb`

Poi, eseguite questo comando:

`mysql_secure_installation`

!!! tip "Suggerimento"

    La versione di mariadb-server che viene abilitata per impostazione predefinita in Rocky Linux 8.5 è la 10.3.32. È possibile installare 10.5.13 abilitando il modulo:

    ```
    dnf module enable mariadb:10.5
    ```


    E poi installare `mariadb`. Dalla versione 10.4.6 di MariaDB, sono disponibili comandi specifici MariaDB che puoi usare al posto dei vecchi comandi `mysql` prefissati. Questi includono il precedentemente menzionato `mysql_secure_installation` che ora può essere chiamato con la versione MariaDB `mariadb-secure-installation`.

Viene visualizzata una finestra di dialogo:

```
NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, you will need the current
password for the root user.  If you have just installed MariaDB, and
you have not set the root password yet, the password will be blank,
so you should just press enter here.

Enter current password for root (enter for none):
```

Trattandosi di una nuova installazione, non è stata impostata alcuna password di root. Basta premere invio qui.

La parte successiva del dialogo continua:

```
OK, successfully used password, moving on...

Setting the root password ensures that nobody can log into the MariaDB
root user without the proper authorisation.

Set root password? [Y/n]
```

È' assolutamente _necessario_ avere una password di root impostata. Ti consigliamo di capire cosa dovrebbe essere e documentarlo in un gestore di password da qualche parte in modo da poterlo estrarre se necessario. Iniziate premendo 'Invio' per accettare il valore predefinito "Y". Questo farà apparire la finestra di dialogo della password:

```
New password:
Re-enter new password:
```

Inserisci la password scelta e poi confermala inserendola di nuovo. Se questo ha successo, otterrete la seguente finestra di dialogo:

```
Password updated successfully!
Reloading privilege tables..
 ... Success!
```

Il prossimo dialogo riguarda l'utente anonimo:

```
By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n]
```

La risposta qui è "Y", quindi basta premere 'Invio' per accettare l'impostazione predefinita.

La finestra di dialogo procede alla sezione che si occupa di permettere all'utente root di accedere da remoto:

```
... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n]
```

root dovrebbe essere necessario solo localmente sulla macchina. Quindi accettate anche questo default premendo 'Invio'.

La finestra di dialogo si sposta poi sul database 'test' che è installato automaticamente con _mariadb-server_:

```
... Success!


By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n]
```

Di nuovo, la risposta qui è quella predefinita, quindi basta premere 'Invio' per rimuoverla.

Infine, la finestra di dialogo chiede se si desidera ricaricare i privilegi:

```
- Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n]
```

Anche in questo caso, premere "Invio". Se tutto ha funzionato, si riceverà questo messaggio:

```
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

MariaDB sarà ora pronto all'uso.

### Modifiche a Rocky 9.0

Rocky Linux 9.0 utilizza `mariadb-server-10.5.13-2` come versione predefinita di mariadb-server. A partire dalla versione 10.4.3, un nuovo plugin è abilitato automaticamente nel server che cambia la finestra di dialogo `mariadb-secure-installation`. Quel plugin è l'autenticazione `unix-socket`. [Questo articolo](https://mariadb.com/kb/en/authentication-plugin-unix-socket/) spiega bene la nuova funzione. Essenzialmente, l'uso dell'autenticazione unix-socket utilizza le credenziali dell'utente connesso per accedere al database. Fa in modo che se l'utente root, ad esempio, accede e quindi utilizza `mysqladmin` per creare o eliminare un database (o qualsiasi altra funzione) non viene richiesta alcuna password per l'accesso. Stesso funzionamento con `mysql`. Ciò significa anche che non c'è una password da compromettere in remoto. Ciò dipende dalla sicurezza degli utenti impostati sul server per la protezione del database.

La seconda finestra di dialogo durante `mariadb-secure-installation` dopo l'impostazione della password per l'utente amministrativo è:

```
Switch to unix_socket authentication Y/n
```

L'impostazione predefinita è "Y", ma anche se si risponde "n", con il plugin abilitato non viene richiesta una password per l'utente, almeno non dall'interfaccia della riga di comando. È possibile specificare password o nessuna password e entrambi funzionano:

```
mysql

MariaDB [(none)]>
```

```
mysql -p
Inserire la password:

MariaDB [(none)]>
```

Per ulteriori informazioni su questa funzione, fare riferimento al link qui sopra. C'è un modo per disattivare questo plugin e tornare ad avere la password come campo obbligatorio, che è anche dettagliato all'interno di tale collegamento.

## Conclusione

Un server di database, come _mariadb-server_, può essere usato per molti scopi. A causa della popolarità del CMS Wordpress, si trova spesso sui server web. Prima di eseguire il database in produzione, tuttavia, è bene rafforzarne la sicurezza.
